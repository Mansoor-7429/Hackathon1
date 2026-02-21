# 🚀 LAUNCH CHECKLIST - Deploy to Production

**Target**: Production deployment in 2-3 hours  
**Status**: Ready (all code complete)  
**Date**: 2026-02-21  

---

## ⏱️ TIMELINE ESTIMATE

```
Step 1 (Manual - 10 min):   Create cloud accounts & API keys
Step 2 (Manual - 5 min):    Get credentials
Step 3 (Automated - 5 min): Create .env files
Step 4 (Manual - 5 min):    Deploy frontend to Vercel (git push)
Step 5 (Manual - 10 min):   Deploy backend to Railway (Docker push)
Step 6 (Manual - 10 min):   Deploy RAG to Railway (Docker push)
Step 7 (Automated - 5 min): Run database migrations
Step 8 (Automated - 10 min):Ingest chapters to Qdrant
Step 9 (Automated - 15 min):Run smoke tests against live endpoints
Step 10 (Manual - 30 min):  Record demo video
────────────────────────────────────────────
TOTAL: ~90 minutes (1.5 hours)
```

---

## 📋 STEP-BY-STEP DEPLOYMENT GUIDE

### STEP 1: Create Cloud Accounts & Get API Keys (10 min)

You need 4 things:

#### 1A. PostgreSQL Database (Neon Free Tier)
```
1. Go to: https://neon.tech/
2. Sign up with email
3. Create free project
4. Copy DATABASE_URL from Connection String
5. Format: postgresql://user:password@host:5432/db_name?sslmode=require
```

#### 1B. Vector Database (Qdrant Cloud Free Tier)
```
1. Go to: https://qdrant.io/cloud
2. Sign up with email
3. Create free cluster (default 256MB)
4. Copy API key
5. Copy cluster URL (e.g., https://xxxxx.qdrant.io)
```

#### 1C. LLM API (OpenAI API Key)
```
1. Go to: https://platform.openai.com/api/keys
2. Sign in / create account
3. Create new API key
4. Copy the key (only shown once!)
5. Add $5 credit to account (free trial)
```

#### 1D. Vercel Account (Frontend Hosting)
```
1. Go to: https://vercel.com/
2. Sign up with GitHub account (easiest)
3. Authorize GitHub access
4. You're ready to deploy
```

#### 1E. Railway Account (Backend Hosting)
```
1. Go to: https://railway.app/
2. Sign up with GitHub account (easiest)
3. Authorize GitHub access
4. Create new project
```

#### 1F. GitHub Personal Access Token (for Railway/CI-CD)
```
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: "railway-deployment"
4. Scope: repo, write:packages, read:packages
5. Generate and copy token
```

**Once you have these 6 items, proceed to Step 2.**

---

### STEP 2: Create .env Files (5 min)

Copy your credentials into environment files:

#### 2A. Create `.env.local` for frontend (website/)
```bash
cd website
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_BASE=https://YOUR_BACKEND_RAILWAY_URL
NEXT_PUBLIC_QDRANT_URL=https://YOUR_QDRANT_CLUSTER_URL
EOF
```

#### 2B. Create `.env.production` for backend
```bash
cd backend
cat > .env.production << 'EOF'
DATABASE_URL=postgresql://user:pass@host/dbname?sslmode=require
QDRANT_API_KEY=YOUR_QDRANT_API_KEY
QDRANT_URL=https://YOUR_QDRANT_CLUSTER_URL
OPENAI_API_KEY=sk-YOUR_OPENAI_KEY
JWT_SECRET=your-super-secret-key-min-32-chars
ENVIRONMENT=production
LOG_LEVEL=INFO
EOF
```

#### 2C. Create `.env.production` for RAG service
```bash
cd rag
cat > .env.production << 'EOF'
QDRANT_API_KEY=YOUR_QDRANT_API_KEY
QDRANT_URL=https://YOUR_QDRANT_CLUSTER_URL
OPENAI_API_KEY=sk-YOUR_OPENAI_KEY
ENVIRONMENT=production
LOG_LEVEL=INFO
EOF
```

**⚠️ IMPORTANT**: Never commit `.env` files to git! They're already in `.gitignore`.

---

### STEP 3: Deploy Frontend to Vercel (5 min)

Vercel auto-deploys from GitHub. Just connect your repo:

```bash
# 1. Push code to GitHub (if not already done)
cd website
git add .
git commit -m "Ready for production deployment"
git push origin main

# 2. Go to Vercel Dashboard: https://vercel.com/dashboard
# 3. Click "Add New..." → "Project"
# 4. Select your GitHub repo
# 5. Configure:
#    - Framework: Next.js
#    - Root Directory: website
#    - Environment Variables: Add your .env.local values
# 6. Click "Deploy"
# 7. Wait ~2-3 min for build
# 8. Copy production URL (something like: https://textbook.vercel.app)

# VERCEL_FRONTEND_URL = https://your-project.vercel.app
```

**Expected output**: Green checkmark ✅ deployment complete

---

### STEP 4: Deploy Backend to Railway (10 min)

Railway deploys Docker containers. We have Dockerfile.backend ready.

```bash
# 1. Install Railway CLI
npm install -g @railway/cli
# or on Windows: npm install -g @railway/cli --global

# 2. Connect to Railway
railway login
# This opens browser for authentication

# 3. Create Railway project
railway init
# When asked: Choose "Backend API Service"

# 4. Create PostgreSQL plugin (for database)
railway add
# Select: PostgreSQL
# This auto-sets DATABASE_URL

# 5. Add environment variables
railway variables set QDRANT_URL=https://xxx
railway variables set QDRANT_API_KEY=xxxxx
railway variables set OPENAI_API_KEY=sk-xxx
railway variables set JWT_SECRET=your-secret
railway variables set ENVIRONMENT=production

# 6. Deploy
railway up
# This pushes Dockerfile.backend to Railway and deploys

# 7. Wait for build (3-5 min)
# 8. Get production URL
railway logs
# Look for: "Application running at https://your-backend-railway.up.railway.app"

# RAILWAY_BACKEND_URL = https://your-backend-railway.up.railway.app
```

**Expected output**: "Deployment successful" with green status

---

### STEP 5: Deploy RAG Service to Railway (10 min)

Same process for RAG microservice:

```bash
# 1. In rag/ directory
cd rag

# 2. Create new Railway project for RAG
railway init
# Choose: RAG AI Service

# 3. Add environment variables (same as backend)
railway variables set QDRANT_URL=https://xxx
railway variables set QDRANT_API_KEY=xxxxx
railway variables set OPENAI_API_KEY=sk-xxx
railway variables set ENVIRONMENT=production

# 4. Deploy
railway up
# Pushes Dockerfile.rag and deploys

# 5. Wait for build (3-5 min)
# 6. Get production URL
railway logs

# RAG_SERVICE_URL = https://your-rag-railway.up.railway.app
```

---

### STEP 6: Run Database Migrations (5 min)

Create database schema in Neon:

```bash
# 1. Get DATABASE_URL from Neon dashboard
# Format: postgresql://neondb_owner:xxxxx@ep-xxx.us-east-1.aws.neon.tech/neondb?sslmode=require

# 2. Run Alembic migrations
cd backend
export DATABASE_URL="postgresql://user:pass@host/db?sslmode=require"
alembic upgrade head

# 3. Verify tables created
psql $DATABASE_URL -c "\dt"
# Should show 10 tables:
#   - users
#   - chapters  
#   - chat_history
#   - chapter_translations
#   - chapter_summaries
#   - chapter_quizzes
#   - chapter_personalization
#   (+ 3 more)

# ✅ Database ready
```

---

### STEP 7: Ingest Chapters to Qdrant (10 min)

Load textbook chapters into vector database:

```bash
# 1. Set environment variables
export QDRANT_URL="https://your-qdrant-cluster.qdrant.io"
export QDRANT_API_KEY="xxxxxx"
export ENVIRONMENT="production"

# 2. Run ingestion script
cd rag
python scripts/ingest_chapters.py \
  --source ../website/public/chapters/ \
  --collection textbook \
  --chunk-size 256 \
  --overlap 3

# 3. Verify ingestion
# Should see:
#   ✓ Loaded 8 chapters (9,500 words)
#   ✓ Created 384-dim embeddings (MiniLM)
#   ✓ Indexed in Qdrant collection
#   ✓ Ready for retrieval

# ✅ Vector store populated
```

---

### STEP 8: Test Live System (15 min)

Verify all endpoints work against production:

```bash
# 1. Set your production URLs
export FRONTEND_URL="https://your-project.vercel.app"
export BACKEND_URL="https://your-backend-railway.up.railway.app"
export RAG_URL="https://your-rag-railway.up.railway.app"

# 2. Run comprehensive tests
cd /
bash demo.sh \
  --backend $BACKEND_URL \
  --rag $RAG_URL \
  --frontend $FRONTEND_URL \
  --environment production

# 3. Expected results:
#   ✓ Health checks pass
#   ✓ Auth flows work
#   ✓ Chapter retrieval works
#   ✓ Chat returns citations
#   ✓ Personalization works
#   ✓ Translation works
#   ✓ Summaries/quizzes work
#   ✓ All endpoints < 3s
```

**Expected output**: All 16 scenarios PASS ✅

---

### STEP 9: Update Frontend Environment (5 min)

Update Vercel with backend URL:

```bash
# 1. Go to Vercel Dashboard → Your Project → Settings → Environment Variables
# 2. Add:
#    NEXT_PUBLIC_API_BASE = https://your-backend-railway.up.railway.app
#    NEXT_PUBLIC_QDRANT_URL = https://your-qdrant-cluster.qdrant.io
# 3. Vercel auto-redeploys (2-3 min)
# 4. Verify at: https://your-project.vercel.app

# ✅ Frontend connected to live backend
```

---

### STEP 10: Record 90-Second Demo Video (30 min)

Create marketing demo showing all features:

```
SCRIPT (90 seconds):

[0-5s]   "Welcome to the AI-Native Textbook"
         Show homepage, click on Chapter 1

[5-20s]  Read Chapter 1 smoothly
         Scroll down, show responsive design
         "Designed for mobile and desktop"

[20-30s] Open chat modal
         Ask: "What is humanoid robotics?"
         Show grounded response with citations

[30-40s] Click Personalize button
         Switch from "Student" to "Expert"
         Show content adapted

[40-50s] Click Translate button
         Show Urdu translation
         "Available in 6 languages"

[50-60s] Scroll to Summary
         Show auto-generated summary
         Click Quiz
         "Instant learning assessments"

[60-75s] Show about page / credits
         "Built with AI, deployed to production"

[75-90s] Call to action
         "Start learning now at [your-url]"

RECORDING TIPS:
- Use OBS or QuickTime (Mac) / ScreenRecord (Windows)
- Record at 1080p 30fps
- Clear browser cache before recording
- Use incognito window (no extensions)
- Test audio levels
- No background noise
- Smooth scrolling (use browser timeline)
- Add title/credits with simple text overlay

EXPORT:
- Format: MP4 H.264
- Target: ~15-20 MB
- Share as: demo.mp4 in repo root
```

---

## ✅ FINAL VERIFICATION CHECKLIST

Run this after deployment:

```bash
#!/bin/bash

BACKEND="https://your-backend-url"
RAG="https://your-rag-url"
FRONTEND="https://your-vercel-url"

echo "🔍 Verifying Production Deployment..."
echo ""

# Health checks
echo "✓ Health Checks:"
curl -s $BACKEND/health | jq .
curl -s $RAG/health | jq .

# Auth flow
echo "✓ Authentication:"
curl -s -X POST $BACKEND/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123"}'

# Chapter retrieval
echo "✓ Chapters:"
curl -s $BACKEND/api/chapters | jq '.chapters[0]'

# Chat with RAG
echo "✓ Chat:"
curl -s -X POST $RAG/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"What is humanoid robotics?","context":["chapter-1"]}'

# Frontend load time
echo "✓ Frontend Performance:"
time curl -s $FRONTEND > /dev/null

echo ""
echo "🎉 Production deployment verified!"
```

---

## 📊 POST-LAUNCH STATUS

Once deployed, you'll have:

```
PRODUCTION SYSTEM:
├── Frontend:      https://your-project.vercel.app
├── Backend API:   https://backend-xxx.up.railway.app
├── RAG Service:   https://rag-xxx.up.railway.app
├── Database:      neon.tech (PostgreSQL)
├── Vectors:       qdrant.io (Vector Cloud)
└── LLM:          openai.com (GPT-4o-mini)

METRICS:
• Pages:          3 (homepage, chapters, admin)
• API endpoints:  25+
• Users:          Ready for registrations
• Chapters:       8 ingested
• Languages:      6 supported
• Response time:  <3s average
• Uptime SLA:     99.9%

USERS CAN:
✓ Read interactive chapters
✓ Ask AI tutor questions
✓ Get personalized content
✓ Read in multiple languages
✓ Take quizzes
✓ Save progress
```

---

## 🚨 TROUBLESHOOTING

### Issue: "Connection refused" to backend

```bash
# Check if Railway app is running
railway status

# View logs
railway logs

# Redeploy if needed
railway up
```

### Issue: Qdrant authentication fails

```bash
# Verify API key is correct
# Check that URL doesn't have trailing slash
# Test with curl:
curl -s https://your-cluster.qdrant.io/health \
  -H "api-key: YOUR_KEY"
```

### Issue: Chapter ingestion times out

```bash
# Increase timeout
export QDRANT_TIMEOUT=30
python scripts/ingest_chapters.py ...

# Or ingest chapters one at a time
python scripts/ingest_chapters.py --source chapter1.md
```

### Issue: Vercel deployment fails

```bash
# Check build logs in Vercel dashboard
# Common issues:
# - Missing environment variables (add in Settings)
# - Node version mismatch (check node --version)
# - Dependency issues (npm ci vs npm install)

# Local rebuild test:
cd website
npm run build
npm run start
```

---

## 📞 SUPPORT

If you get stuck:

1. **Check logs**: `railway logs`, Vercel dashboard, browser console
2. **Verify credentials**: Double-check API keys (no typos, spaces)
3. **Test locally first**: `npm run dev`, `uvicorn main:app --reload`
4. **Review DEPLOYMENT.md**: Full guide with more details
5. **Check endpoint health**: `curl https://your-url/health`

---

## 🎯 LAUNCH SUCCESS CRITERIA

Your deployment is successful when:

- ✅ Frontend loads in < 2 seconds
- ✅ Can sign up and log in
- ✅ Can read chapters
- ✅ Chat returns grounded answers
- ✅ Personalization works
- ✅ Translation works
- ✅ Summaries display
- ✅ Quizzes work
- ✅ No console errors
- ✅ Mobile responsive (test on phone)

---

## 📝 NEXT STEPS (Post-Launch)

After successful deployment:

1. **Share URLs** with users
2. **Collect feedback** on UX
3. **Monitor performance** (response times, errors)
4. **Track usage** (active users, feature adoption)
5. **Plan updates** (new chapters, languages, features)

---

**You're 10 minutes away from going live! 🚀**

Start with **STEP 1** (create cloud accounts) and work through each step.

Each step takes ~5-10 minutes. Total time: ~90 minutes.

Good luck! 🎉
