# Phase 8 Execution Checklist: Deployment & Polish

**Date**: 2026-02-21  
**Status**: Ready for Execution  
**Estimated Time**: 2-3 hours  

---

## Pre-Deployment Verification (Phase 8.1)

### Code Quality Checks

#### T070: Linting & Type Checking

```bash
# Frontend: ESLint
cd website
npm run lint

# Expected: 0 errors (warnings OK)
```

```bash
# Backend: Black formatter + isort + mypy
cd backend
black src/ --check
isort src/ --check-only
mypy src/ --ignore-missing-imports

# Expected: All pass
```

```bash
# RAG: Black formatter + isort
cd rag
black src/ --check
isort src/ --check-only

# Expected: All pass
```

### Security Audit (T068)

**Checklist:**
- [ ] No secrets in `.env.example` (only templates)
- [ ] No AWS keys/API keys in code
- [ ] No hardcoded URLs (use environment variables)
- [ ] No sensitive data in logs
- [ ] CORS configured (not wildcard)
- [ ] JWT secret is strong (32+ chars in production)
- [ ] Database passwords never logged
- [ ] SQL injection prevented (using ORM)

**Verify:**
```bash
# Check for common secrets
grep -r "OPENAI_API_KEY\|sk-" backend/ rag/ website/ --include="*.py" --include="*.ts" --include="*.tsx" || echo "✓ No hardcoded keys found"

# Check for hardcoded URLs
grep -r "http://localhost\|hardcoded\|TODO\|FIXME" backend/ rag/ website/ --include="*.py" --include="*.ts" --include="*.tsx" || echo "✓ No hardcoded URLs found"
```

### Integration Testing (T067)

**Manual smoke tests covering main flows:**

```bash
# 1. Test chapter reading flow
#    Homepage → Chapter list → Read chapter → Navigation → Back

# 2. Test chatbot flow
#    Chapter → Open chat → Ask question → Get answer with citations

# 3. Test personalization flow
#    Chapter → Personalize → Select background → See adapted content

# 4. Test translation flow
#    Chapter → Translate → Toggle language → See Urdu content

# 5. Test summary/quiz flow
#    Chapter → Scroll to bottom → View summary → Take quiz → See score

# 6. Test auth flow
#    Signup → Login → Get token → Use in chat → Refresh token → Logout
```

### Mobile Responsiveness (T065)

**Viewport testing (375px minimum):**

```bash
# Test with Chrome DevTools:
# 1. Open each page at 375px width
# 2. Check for horizontal scroll (should not exist)
# 3. Verify text is 16px+ (readable)
# 4. Verify images scale properly
# 5. Verify touch targets are 48x48px minimum
# 6. Verify navigation is accessible

Pages to test:
- / (homepage)
- /chapters/01-introduction (chapter reader)
- Chat modal
- Personalize modal
```

### Performance Optimization (T066)

```bash
# Lighthouse audit (requires local server running)
npm run build:website
npm run start:website

# Then run Lighthouse from Chrome DevTools:
# Target: 90+ score on all metrics
# - Performance: 90+
# - Accessibility: 90+
# - Best Practices: 90+
# - SEO: 90+
```

---

## Production Environment Setup (Phase 8.2)

### Step 1: Create Cloud Accounts & Services

**Neon PostgreSQL:**
```bash
# 1. Go to https://neon.tech
# 2. Sign up
# 3. Create project "textbook"
# 4. Create database "textbook_db"
# 5. Copy connection string
# Save: NEON_DATABASE_URL
```

**Qdrant Cloud:**
```bash
# 1. Go to https://cloud.qdrant.io
# 2. Sign up
# 3. Create cluster "textbook"
# 4. Copy URL and API key
# Save: QDRANT_URL, QDRANT_API_KEY
```

**OpenAI API:**
```bash
# 1. Go to https://platform.openai.com
# 2. Sign up
# 3. Create API key
# Save: OPENAI_API_KEY
```

### Step 2: Update Environment Files

**Create `.env.production`:**
```bash
cat > .env.production << 'EOF'
# Frontend (website/.env.production.local)
NEXT_PUBLIC_API_BASE_URL=https://api.textbook.railway.app
NEXT_PUBLIC_RAG_API_URL=https://rag.textbook.railway.app
NEXT_PUBLIC_ENVIRONMENT=production

# Backend (backend/.env)
DATABASE_URL=postgresql://USER:PASSWORD@HOST/textbook_db
RAG_SERVICE_URL=https://rag.textbook.railway.app
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
CORS_ORIGINS=https://textbook.vercel.app,https://api.textbook.railway.app
DEBUG=false
LOG_LEVEL=INFO

# RAG (rag/.env)
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
DEBUG=false
LOG_LEVEL=INFO
EOF
```

---

## Deployment (Phase 8.3)

### T062: Deploy Frontend to Vercel

```bash
# 1. Go to https://vercel.com
# 2. Import GitHub repository
# 3. Select "website" as root directory
# 4. Add environment variables:
#    - NEXT_PUBLIC_API_BASE_URL=https://api.textbook.railway.app
#    - NEXT_PUBLIC_RAG_API_URL=https://rag.textbook.railway.app
#    - NEXT_PUBLIC_ENVIRONMENT=production
# 5. Deploy

# Verify:
curl https://textbook.vercel.app
# Expected: Homepage HTML response
```

### T063: Deploy Backend to Railway

```bash
# 1. Go to https://railway.app
# 2. Create new project
# 3. Connect GitHub repository
# 4. Select "backend" directory
# 5. Add environment variables (from .env):
#    - DATABASE_URL=...
#    - RAG_SERVICE_URL=...
#    - OPENAI_API_KEY=...
#    - QDRANT_URL=...
#    - QDRANT_API_KEY=...
#    - CORS_ORIGINS=...
# 6. Set start command: python -m backend.src.main
# 7. Deploy

# Verify:
curl https://api.textbook.railway.app/health
# Expected: {"status": "healthy"}
```

### T064: Deploy RAG to Railway

```bash
# 1. In same Railway project, add service
# 2. Connect GitHub, select "rag" directory
# 3. Add environment variables:
#    - OPENAI_API_KEY=...
#    - QDRANT_URL=...
#    - QDRANT_API_KEY=...
# 4. Set start command: python -m rag.src.main
# 5. Deploy

# Verify:
curl https://rag.textbook.railway.app/health
# Expected: {"status": "healthy"}
```

### T065: Database Migrations

```bash
# Connect to Neon and run migrations
psql postgresql://USER:PASSWORD@HOST/textbook_db < backend/src/db/migrations/001_initial_schema.sql

# Verify:
psql postgresql://USER:PASSWORD@HOST/textbook_db
\dt  # Should show 10 tables
SELECT count(*) FROM users;  # Should be 0 initially
```

### T066: Ingest Chapters to Qdrant

```bash
# Run from project root
cd rag
python -m scripts.ingest_chapters \
  --chapters-dir ../website/public/chapters \
  --qdrant-url https://xxxxx.qdrant.io \
  --qdrant-api-key xxxxxxxxxxxxx

# Verify in Qdrant Cloud dashboard:
# - Collection "chapters" exists
# - ~3,000+ points ingested (8 chapters × ~400 chunks)
```

---

## Validation & Testing (Phase 8.4)

### T067: End-to-End Testing

```bash
# Run automated demo script
chmod +x demo.sh
./demo.sh https://api.textbook.railway.app

# Expected output:
# ✅ 16/16 demo scenarios pass
# ✅ All features working
```

### Manual Verification

**Homepage:**
```bash
curl https://textbook.vercel.app
# Verify: Homepage loads, shows 8 chapters
```

**Chapter Reading:**
```bash
curl https://api.textbook.railway.app/chapters
# Verify: Returns list of 8 chapters
curl https://api.textbook.railway.app/chapters/01-introduction
# Verify: Returns chapter content
```

**Authentication:**
```bash
# Signup
curl -X POST https://api.textbook.railway.app/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "Test123!",
    "background": "student"
  }'
# Verify: Returns access_token and refresh_token

# Login
curl -X POST https://api.textbook.railway.app/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!"
  }'
# Verify: Returns tokens
```

**Chatbot:**
```bash
TOKEN=$(...)  # From signup/login response
curl -X POST https://api.textbook.railway.app/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What is humanoid robotics?",
    "chapter_id": "02-humanoid-fundamentals"
  }'
# Verify: Returns grounded answer with citations
```

**All Features:**
```bash
# Test each endpoint from API.md
# GET /chapters
# GET /chapters/{id}
# GET /chapters/search
# GET /chapters/stats
# POST /auth/signup
# POST /auth/login
# POST /auth/refresh
# POST /chat
# GET /chat/history
# GET /personalize/backgrounds
# POST /personalize/chapter
# GET /translate/languages
# POST /translate/chapter
# GET /summaries/chapters/{id}
# GET /quizzes/chapters/{id}
# POST /quizzes/chapters/{id}/submit
```

---

## Demo Recording (Phase 8.5)

### T068: Record 90-Second Demo

**Script:**
```
00:00 - 00:10  (10s)
  Show homepage, explain: "AI-Native Textbook for Physical AI & Robotics"
  Pan through chapter list, show responsive design
  Subtitle: "MVP with 8 chapters, <45 min read time"

00:10 - 00:25  (15s)
  Click on chapter, show reading interface
  Scroll through chapter, show progress bar
  Subtitle: "Clean, responsive reading experience"
  
00:25 - 00:40  (15s)
  Open chat modal, ask "What is humanoid robotics?"
  Show answer appearing, highlight citations
  Subtitle: "RAG chatbot with grounded, cited answers"

00:40 - 00:50  (10s)
  Click translate, toggle to Urdu
  Show Urdu content appearing
  Subtitle: "One-click multi-language translation"

00:50 - 01:10  (20s)
  Scroll to summary section, show auto-generated summary
  Show quiz questions
  Answer 2-3 questions, show score
  Subtitle: "Auto-generated summaries & quizzes"

01:10 - 01:20  (10s)
  Click personalize, select "intermediate" level
  Show content adapting
  Subtitle: "Content personalization per background"

01:20 - 01:30  (10s)
  Show signup/login flow quickly
  Highlight "User authentication with JWT"
  Subtitle: "Secure authentication, chat history"

01:30 - 01:35  (5s)
  Quick mobile view showing responsive design
  Subtitle: "Works on 375px to 4K screens"

01:35 - 01:40  (5s)
  Final slide: "AI-Native Textbook for Physical AI & Robotics"
  "MVP Complete: All 7 user stories implemented"
  "https://textbook.vercel.app"
```

**Recording Tips:**
1. Use browser zoom 125% for readability
2. Disable notifications to avoid popups
3. Use screen capture tool (OBS, ScreenFlow, or built-in)
4. Keep steady transitions, no jerky movements
5. Add audio narration or captions
6. Keep video under 90 seconds (target 75-85s)
7. Export as MP4 @ 1080p, 30fps
8. Upload to GitHub releases or shared link

---

## Final Validation (Phase 8.6)

### T069: Documentation Updates

**Checklist:**
- [ ] README.md references all docs
- [ ] DEPLOYMENT.md has complete setup guide
- [ ] API.md has all endpoints documented
- [ ] PROJECT_SUMMARY.md lists all features
- [ ] COMPLETION.md shows 79% status
- [ ] demo.sh is executable and working
- [ ] Comments in code are clear

### T070: Health Checks on Live System

```bash
# Frontend
curl -I https://textbook.vercel.app
# Expected: HTTP 200

# Backend
curl https://api.textbook.railway.app/health
# Expected: {"status": "healthy"}

# RAG
curl https://rag.textbook.railway.app/health
# Expected: {"status": "healthy"}

# Database
curl https://api.textbook.railway.app/chapters
# Expected: List of 8 chapters

# Qdrant
curl -X GET https://rag.textbook.railway.app/rag/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "test"}'
# Expected: Successful response or error from LLM

# Full integration
./demo.sh https://api.textbook.railway.app
# Expected: All 16 scenarios pass
```

### T071: Final Validation Checklist

- [ ] All health checks pass
- [ ] No console errors in browser
- [ ] All API endpoints respond correctly
- [ ] Database connectivity verified
- [ ] Qdrant ingestion complete
- [ ] OpenAI API is responding
- [ ] CORS allows frontend requests
- [ ] Logging is working (check Railway dashboard)
- [ ] Performance is acceptable (<3s responses)
- [ ] Mobile responsive on 375px
- [ ] Demo video created and saved

---

## Production Monitoring

### Logs
```bash
# View backend logs
# Railway Dashboard → Backend Service → Logs

# View RAG logs
# Railway Dashboard → RAG Service → Logs

# Check for errors:
filter by ERROR, WARN
```

### Metrics to Monitor
- API response time (target: <1s avg)
- Error rate (target: <0.1%)
- Database connection pool (target: <50% used)
- Qdrant latency (target: <500ms)
- OpenAI API usage (target: <100 requests/hour)

### Alerts to Setup
- Response time > 3s
- Error rate > 1%
- Service down
- Database connection lost
- Qdrant unreachable

---

## Rollback Plan

If deployment fails:

```bash
# Vercel
1. Go to Deployments
2. Select previous working version
3. Click "Promote to Production"

# Railway
1. Go to Deployments
2. Select previous version
3. Click "Redeploy"

# Database
- Backups are automatic on Neon
- Restore from backup if needed
```

---

## Success Criteria (All Must Pass)

- ✅ Frontend loads at https://textbook.vercel.app
- ✅ Backend healthy at https://api.textbook.railway.app/health
- ✅ RAG healthy at https://rag.textbook.railway.app/health
- ✅ All 25+ API endpoints respond
- ✅ Chapters ingested to Qdrant (3000+ vectors)
- ✅ Demo script passes all 16 scenarios
- ✅ Mobile responsive (375px+)
- ✅ <3s response time
- ✅ <0.1% error rate
- ✅ Demo video recorded and saved

---

## Timeline & Ownership

| Step | Task | Time | Status |
|------|------|------|--------|
| 1 | Cloud account setup | 30 min | ⏳ |
| 2 | Deploy frontend | 30 min | ⏳ |
| 3 | Deploy backend | 30 min | ⏳ |
| 4 | Deploy RAG | 30 min | ⏳ |
| 5 | Database setup | 20 min | ⏳ |
| 6 | Ingest chapters | 20 min | ⏳ |
| 7 | Run E2E tests | 30 min | ⏳ |
| 8 | Record demo | 20 min | ⏳ |
| **Total** | | **~3 hours** | ⏳ |

---

**Status**: 🚀 READY FOR PHASE 8 EXECUTION  
**Next**: Execute deployment steps in order  
**Expected Completion**: 2026-02-21 evening
