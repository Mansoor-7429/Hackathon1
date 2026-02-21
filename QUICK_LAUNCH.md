# ⚡ QUICK LAUNCH - 30 Minute Version

**TL;DR**: You have everything ready. Follow these 5 commands to go live.

---

## 🎯 Prerequisites (Do First)

Get these 3 things, then run the commands below:

```
1. DATABASE_URL=postgresql://user:pass@host/db?sslmode=require   (from Neon)
2. QDRANT_URL + QDRANT_API_KEY                                    (from Qdrant Cloud)
3. OPENAI_API_KEY=sk-xxxxx                                        (from OpenAI)
```

**Don't have these? See LAUNCH_STEPS.md STEP 1 (takes 10 min)**

---

## 🚀 Deploy in 5 Steps (30 minutes)

### 1️⃣ Frontend → Vercel (2 min)

```bash
cd website
git add .
git commit -m "Deploy to production"
git push origin main

# Then go to: https://vercel.com/dashboard
# Click "Add Project" → Select repo → Deploy
# Copy your Vercel URL
```

✅ **Result**: `https://your-project.vercel.app`

---

### 2️⃣ Backend → Railway (10 min)

```bash
cd backend

# Install Railway CLI
npm install -g @railway/cli

# Connect
railway login
railway init

# Add database
railway add
# Choose: PostgreSQL

# Add secrets
railway variables set QDRANT_URL=your_qdrant_url
railway variables set QDRANT_API_KEY=your_key
railway variables set OPENAI_API_KEY=your_key
railway variables set JWT_SECRET=generate-random-32-char-string

# Deploy
railway up
```

✅ **Result**: `https://backend-xxx.up.railway.app`

---

### 3️⃣ RAG Service → Railway (10 min)

```bash
cd rag

railway init
# Choose: New Service

railway variables set QDRANT_URL=your_qdrant_url
railway variables set QDRANT_API_KEY=your_key
railway variables set OPENAI_API_KEY=your_key

railway up
```

✅ **Result**: `https://rag-xxx.up.railway.app`

---

### 4️⃣ Database Migrations (3 min)

```bash
cd backend
export DATABASE_URL="postgresql://..."
alembic upgrade head
```

✅ **Result**: 10 tables created in Neon

---

### 5️⃣ Ingest Chapters to Qdrant (5 min)

```bash
cd rag
export QDRANT_URL="https://..."
export QDRANT_API_KEY="..."

python scripts/ingest_chapters.py \
  --source ../website/public/chapters/ \
  --collection textbook
```

✅ **Result**: All 8 chapters searchable

---

## ✨ Done! Your App is LIVE

```
Frontend: https://your-project.vercel.app
Backend:  https://backend-xxx.up.railway.app
RAG:      https://rag-xxx.up.railway.app

Visit https://your-project.vercel.app
```

---

## 🧪 Quick Test

```bash
# Test backend health
curl https://your-backend-url/health

# Test chat
curl -X POST https://your-rag-url/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"What is AI?","context":["ch1"]}'

# Visit frontend
open https://your-project.vercel.app
```

---

## 📺 Record Demo (Optional)

Show off your work:

1. Open browser, go to your deployed URL
2. Click record (QuickTime/OBS)
3. Read a chapter
4. Ask chat a question
5. Show personalization
6. Show translation
7. Stop at 90 seconds
8. Save as demo.mp4

---

## 🆘 Stuck?

- **Backend won't deploy?** → Check `railway logs`
- **Frontend 404 errors?** → Check environment vars in Vercel Settings
- **Chat fails?** → Verify QDRANT_API_KEY + OPENAI_API_KEY
- **Database errors?** → Check DATABASE_URL format from Neon

**Full troubleshooting**: See `DEPLOYMENT.md` or `PHASE_8_CHECKLIST.md`

---

**Total time: ~30 minutes**  
**You're 30 minutes from launch! 🎉**
