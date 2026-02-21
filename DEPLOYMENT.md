# Deployment Guide: AI-Native Textbook

This guide covers deployment of the AI-Native Textbook system to production using Vercel (frontend), Railway (backend + RAG), and cloud services (Neon PostgreSQL, Qdrant Cloud).

---

## Prerequisites

- GitHub account (for repository)
- Vercel account (free tier supports deployments)
- Railway account (free tier has $5/month credit)
- Neon account (free tier PostgreSQL)
- Qdrant Cloud account (free tier available)
- OpenAI API key (paid account, ~$5-10/month estimated)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        VERCEL                               │
│              Frontend: Next.js 14                            │
│              URL: https://textbook.vercel.app               │
└────────────────────────┬─────────────────────────────────────┘
                         │ HTTPS API calls
┌────────────────────────▼─────────────────────────────────────┐
│                       RAILWAY                                │
│  Backend: FastAPI   │  RAG: Python                          │
│  Port: 8000         │  Port: 8001                           │
└────────┬─────────────┼─────────────────┬─────────────────────┘
         │             │                 │
    ┌────▼─────┐   ┌───▼────────┐   ┌───▼──────────┐
    │   NEON   │   │ QDRANT     │   │  OPENAI      │
    │PostgreSQL│   │  CLOUD     │   │   API        │
    └──────────┘   └────────────┘   └──────────────┘
```

---

## Step 1: Setup Cloud Services

### 1.1 Neon PostgreSQL (Database)

1. Go to https://neon.tech
2. Sign up for free account
3. Create new project "textbook"
4. Create database "textbook_db"
5. Copy connection string:
   ```
   postgresql://username:password@host/textbook_db
   ```
6. **Save this for later** (needed in backend environment)

### 1.2 Qdrant Cloud (Vector Database)

1. Go to https://cloud.qdrant.io
2. Sign up for free account
3. Create new cluster "textbook"
4. Copy cluster URL and API key:
   ```
   URL: https://xxxxx.qdrant.io
   API_KEY: xxxxxxxxxxxxx
   ```
5. **Save these for later** (needed in backend & RAG)

### 1.3 OpenAI API Key

1. Go to https://platform.openai.com
2. Sign up or log in
3. Create API key: https://platform.openai.com/api/keys
4. Copy key:
   ```
   OPENAI_API_KEY: sk-xxxxxxxxxxxxx
   ```
5. **Save this for later** (needed in RAG service)

---

## Step 2: Prepare Repository

### 2.1 Create Production Environment Files

Create `.env.production` in root:
```bash
# Frontend (website/.env.production.local)
NEXT_PUBLIC_API_BASE_URL=https://api.textbook.railway.app
NEXT_PUBLIC_RAG_API_URL=https://rag.textbook.railway.app
NEXT_PUBLIC_ENVIRONMENT=production

# Backend (backend/.env.production)
DATABASE_URL=postgresql://username:password@host/textbook_db
RAG_SERVICE_URL=https://rag.textbook.railway.app
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
CORS_ORIGINS=https://textbook.vercel.app,https://api.textbook.railway.app
DEBUG=false
LOG_LEVEL=INFO

# RAG (rag/.env.production)
OPENAI_API_KEY=sk-xxxxxxxxxxxxx
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
DEBUG=false
LOG_LEVEL=INFO
```

### 2.2 Update Next.js Config for Production

Verify `website/next.config.js` has:
```javascript
const nextConfig = {
  reactStrictMode: true,
  productionBrowserSourceMaps: false,  // Disable source maps in production
  compress: true,
  images: {
    unoptimized: true,  // Keep for simplicity
  },
  async rewrites() {
    return {
      beforeFiles: [
        {
          source: '/api/:path*',
          destination: process.env.NEXT_PUBLIC_API_BASE_URL
            ? `${process.env.NEXT_PUBLIC_API_BASE_URL}/:path*`
            : 'http://localhost:8000/:path*',
        },
      ],
    };
  },
};
```

---

## Step 3: Deploy Frontend to Vercel

### 3.1 Connect Repository

1. Go to https://vercel.com
2. Click "New Project"
3. Import GitHub repository
4. Select `website` as root directory
5. Click "Deploy"

### 3.2 Configure Environment Variables

1. Go to project settings → Environment Variables
2. Add production variables:
   ```
   NEXT_PUBLIC_API_BASE_URL=https://api.textbook.railway.app
   NEXT_PUBLIC_RAG_API_URL=https://rag.textbook.railway.app
   NEXT_PUBLIC_ENVIRONMENT=production
   ```
3. Save and redeploy

### 3.3 Verify Deployment

- Frontend URL: `https://textbook.vercel.app` (or your custom domain)
- Check homepage loads
- Verify API base URL is correct

---

## Step 4: Deploy Backend to Railway

### 4.1 Create Railway Project

1. Go to https://railway.app
2. Click "New Project"
3. Select "Deploy from GitHub"
4. Select your repository
5. Click "Deploy Now"

### 4.2 Configure Backend Service

1. Add service environment variables:
   ```
   DATABASE_URL=postgresql://...  (from Neon)
   RAG_SERVICE_URL=https://rag-service-url.railway.app
   OPENAI_API_KEY=sk-...
   QDRANT_URL=https://xxxxx.qdrant.io
   QDRANT_API_KEY=xxxxxxxxxxxxx
   CORS_ORIGINS=https://textbook.vercel.app,https://backend-url.railway.app
   DEBUG=false
   LOG_LEVEL=INFO
   ```

### 4.3 Configure Start Command

1. Go to Deployment settings
2. Set "Start Command":
   ```bash
   python -m backend.src.main
   ```

### 4.4 Setup Dockerfile

Railway uses the included `Dockerfile.backend`:
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY backend/requirements.txt .
RUN pip install -r requirements.txt
COPY backend/ .
EXPOSE 8000
CMD ["python", "-m", "backend.src.main"]
```

### 4.5 Monitor Deployment

- Watch Railway logs for errors
- Verify service is healthy
- Test health endpoint: `GET https://backend-url.railway.app/health`

---

## Step 5: Deploy RAG Service to Railway

### 5.1 Create RAG Service in Same Project

1. In Railway dashboard, click "Add Service"
2. Select "GitHub" deployment
3. Choose RAG directory

### 5.2 Configure RAG Service

1. Add environment variables:
   ```
   OPENAI_API_KEY=sk-...
   QDRANT_URL=https://xxxxx.qdrant.io
   QDRANT_API_KEY=xxxxxxxxxxxxx
   DEBUG=false
   LOG_LEVEL=INFO
   RAG_SERVICE_PORT=8001
   ```

### 5.3 Set RAG Start Command

```bash
python -m rag.src.main
```

### 5.4 Get RAG Service URL

- Railway assigns URL: `https://rag-xxxxx.railway.app`
- Update backend `RAG_SERVICE_URL` to this URL
- Redeploy backend

---

## Step 6: Database Setup

### 6.1 Run Migrations

Connect to Neon and run SQL migrations:

```bash
# Using psql
psql postgresql://user:password@host/textbook_db < backend/src/db/migrations/001_initial_schema.sql
```

Or use Python:
```bash
python -c "from backend.src.db.session import init_db, create_all_tables; init_db('$DATABASE_URL'); create_all_tables()"
```

### 6.2 Verify Database

```bash
psql postgresql://user:password@host/textbook_db
\dt  # List tables
SELECT * FROM chapters LIMIT 1;  # Verify
```

---

## Step 7: Ingest Chapters to Qdrant

### 7.1 Prepare Chapters

Ensure chapters are in `website/public/chapters/`:
```
01-introduction.md
02-humanoid-fundamentals.md
03-computer-vision.md
04-motion-control.md
05-learning.md
06-real-world.md
07-future.md
08-conclusion.md
```

### 7.2 Run Ingest Script

```bash
cd rag
python -m scripts.ingest_chapters \
  --chapters-dir ../website/public/chapters \
  --qdrant-url https://xxxxx.qdrant.io \
  --qdrant-api-key xxxxxxxxxxxxx
```

### 7.3 Verify Ingestion

Check Qdrant Cloud dashboard:
- Collection "chapters" created
- Vectors ingested (should see point count)

---

## Step 8: End-to-End Testing

### 8.1 Test Frontend

```bash
# Visit homepage
https://textbook.vercel.app

# Verify:
✓ Homepage loads
✓ Chapter list visible
✓ Can click chapter to read
✓ Navigation works
✓ Mobile responsive
```

### 8.2 Test Backend Endpoints

```bash
# Health check
curl https://api.textbook.railway.app/health

# List chapters
curl https://api.textbook.railway.app/chapters

# Get chapter
curl https://api.textbook.railway.app/chapters/1

# Signup
curl -X POST https://api.textbook.railway.app/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"testuser","password":"Test123!","background":"student"}'
```

### 8.3 Test RAG Chatbot

```bash
# Chat endpoint
curl -X POST https://rag.textbook.railway.app/rag/chat \
  -H "Content-Type: application/json" \
  -d '{"question":"What is humanoid robotics?"}'

# Should return:
# { "question": "...", "answer": "...", "citations": [...], "is_grounded": true }
```

### 8.4 Test Full User Flow

1. **Sign up**: Create account at frontend
2. **Read chapter**: Open Chapter 1
3. **Ask chatbot**: Ask a question in chat modal
4. **Personalize**: Select different background level
5. **Translate**: Toggle to Urdu
6. **View summary**: Scroll to chapter summary
7. **Take quiz**: Answer quiz questions

---

## Step 9: Environment Variables Summary

### Frontend (`website/.env.production.local`)
```
NEXT_PUBLIC_API_BASE_URL=https://api.textbook.railway.app
NEXT_PUBLIC_RAG_API_URL=https://rag.textbook.railway.app
NEXT_PUBLIC_ENVIRONMENT=production
```

### Backend (`backend/.env` or Railway env vars)
```
DATABASE_URL=postgresql://user:password@host/textbook_db
RAG_SERVICE_URL=https://rag-service-url.railway.app
OPENAI_API_KEY=sk-...
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
CORS_ORIGINS=https://textbook.vercel.app,https://api.textbook.railway.app
DEBUG=false
LOG_LEVEL=INFO
```

### RAG (`rag/.env` or Railway env vars)
```
OPENAI_API_KEY=sk-...
QDRANT_URL=https://xxxxx.qdrant.io
QDRANT_API_KEY=xxxxxxxxxxxxx
DEBUG=false
LOG_LEVEL=INFO
RAG_SERVICE_PORT=8001
```

---

## Step 10: Monitoring & Maintenance

### Health Checks

All services include health check endpoints:
```bash
# Frontend: visit homepage
https://textbook.vercel.app

# Backend: 
curl https://api.textbook.railway.app/health

# RAG:
curl https://rag-service-url.railway.app/health
```

### Logging

Check logs in Railway dashboard:
```
Backend service → Logs → filter by ERROR or WARN
RAG service → Logs → filter by ERROR or WARN
```

### Monitoring

Monitor:
- Response times
- Error rates
- Database connections
- API rate limits
- OpenAI API usage

---

## Troubleshooting

### Frontend Not Loading

1. Check Vercel deployment status
2. Verify API_BASE_URL is correct
3. Check browser console for CORS errors
4. Verify backend is running

### Backend Errors

1. Check Railway logs: `ERROR` entries
2. Verify database connection: `psql $DATABASE_URL`
3. Check environment variables are set
4. Verify OpenAI API key is valid

### Chatbot Not Working

1. Verify RAG service is running
2. Check Qdrant connectivity
3. Verify chapters are ingested: check Qdrant dashboard
4. Test RAG endpoint directly

### Database Connection Issues

1. Verify Neon database is active
2. Check connection string format
3. Verify network access (IP whitelist if needed)
4. Test with psql before deploying

---

## Rollback Procedure

### Vercel
1. Go to Deployments
2. Select previous working deployment
3. Click "Promote to Production"

### Railway
1. Go to Deployments
2. Select previous working version
3. Click "Redeploy"

---

## Production Checklist

- [ ] Neon database created and populated
- [ ] Qdrant Cloud cluster active with chapters ingested
- [ ] OpenAI API key valid and has credit
- [ ] Frontend deployed to Vercel
- [ ] Backend deployed to Railway
- [ ] RAG service deployed to Railway
- [ ] All environment variables configured
- [ ] Health checks passing on all services
- [ ] End-to-end user flows tested
- [ ] CORS configured correctly
- [ ] Logging and monitoring enabled
- [ ] Backup strategy documented
- [ ] Incident response plan documented

---

## Cost Estimate (Monthly)

| Service | Tier | Cost |
|---------|------|------|
| Vercel | Free | $0 |
| Railway | Pay-as-you-go | $5-15 |
| Neon | Free tier | $0 (or upgrade) |
| Qdrant | Free tier | $0 (or upgrade) |
| OpenAI API | Usage-based | $5-20 |
| **Total** | | **~$10-35/month** |

---

## Support & Documentation

- **Vercel**: https://vercel.com/docs
- **Railway**: https://docs.railway.app
- **Neon**: https://neon.tech/docs
- **Qdrant**: https://qdrant.tech/documentation
- **FastAPI**: https://fastapi.tiangolo.com
- **Next.js**: https://nextjs.org/docs

---

**Deployment Date**: 2026-02-21  
**Last Updated**: 2026-02-21  
**Status**: Ready for Production Deployment
