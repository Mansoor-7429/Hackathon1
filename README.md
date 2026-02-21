# AI-Native Textbook for Physical AI & Humanoid Robotics

An interactive, AI-powered textbook that teaches Physical AI & Humanoid Robotics through a modern, mobile-first web application. Features include a RAG chatbot with grounded answers, personalized content, Urdu translation, and auto-generated summaries & quizzes.

## 🎯 Quick Links

- **Project Summary**: [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) (79% complete, 56/71 tasks)
- **Deployment Guide**: [`DEPLOYMENT.md`](DEPLOYMENT.md) (step-by-step production setup)
- **Specification**: [`specs/001-textbook-generation/spec.md`](specs/001-textbook-generation/spec.md)
- **Implementation Plan**: [`specs/001-textbook-generation/plan.md`](specs/001-textbook-generation/plan.md)
- **Tasks & Progress**: [`specs/001-textbook-generation/tasks.md`](specs/001-textbook-generation/tasks.md)

## 📋 Features

### P1 (MVP): Read Interactive Chapters ✅
- 6–8 chapters on Physical AI & Humanoid Robotics
- Clean, distraction-free reading experience
- Mobile-first responsive design (375px–4K)
- **Performance**: < 2s load (desktop), < 3s (mobile)
- **Total read time**: < 45 minutes

### P2: Ask Chatbot Questions
- RAG chatbot with grounded answers
- Citations to exact chapter sections
- Zero hallucinations (grounding validation)
- **Response time**: < 3 seconds
- 90%+ citation accuracy

### P3a: Personalized Content
- User backgrounds (beginner, intermediate, expert)
- Content regenerated per background
- Simpler explanations for beginners
- Advanced applications for experts

### P3b: One-Click Urdu Translation
- Full chapter translation to Urdu
- Formatting preserved (headings, lists, code blocks)
- **Speed**: < 5 seconds (cached)
- **Quality**: ≥ 4/5 rating by native speakers

### P4: Learning Boosters
- Auto-generated 2–3 sentence summaries per chapter
- 5–10 interactive quiz questions per chapter
- Immediate feedback and explanations
- Review suggestions for low scores

## 🏗️ Architecture

```
website/              → Next.js frontend (Vercel)
  ├── src/pages/     → Chapter reader, homepage, auth
  ├── src/components/ → ChapterReader, ChatBot, Summary, Quiz
  └── src/services/  → API wrappers, auth context

backend/              → FastAPI backend (Railway)
  ├── src/models/    → Chapter, User, ChatHistory, Translation, Summary, Quiz
  ├── src/services/  → Auth, chapter, personalization, translation, summary, quiz
  ├── src/api/       → REST routes (/chapters, /chat, /auth, /personalize, /translate, etc.)
  └── src/db/        → Neon PostgreSQL schema, migrations

rag/                  → RAG microservice (Railway)
  ├── src/embedding.py → MiniLM embeddings
  ├── src/retrieval.py → Semantic + keyword search
  ├── src/grounding.py → Validation (no hallucinations)
  ├── src/llm_client.py → OpenAI GPT-4o mini wrapper
  └── scripts/ingest_chapters.py → Chunk & embed chapters

agents/               → Reusable AI skills (bonus)
  ├── generate_summary.py
  ├── generate_quiz.py
  ├── personalize_content.py
  └── translate_content.py
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18+ (frontend)
- **Python** 3.11+ (backend, RAG)
- **Docker** + **Docker Compose** (local development)
- **Git** (version control)

### Local Development (Docker)

1. **Clone and navigate to project**:
   ```bash
   cd <project-root>
   ```

2. **Start services**:
   ```bash
   docker-compose up -d
   ```

   This starts:
   - PostgreSQL (localhost:5432)
   - Qdrant (localhost:6333)
   - Redis (localhost:6379)

3. **Setup frontend**:
   ```bash
   cd website
   npm install
   npm run dev
   ```
   Frontend: http://localhost:3000

4. **Setup backend**:
   ```bash
   cd backend
   pip install -r requirements.txt
   python -m uvicorn src.main:app --reload
   ```
   Backend API: http://localhost:8000
   Health check: http://localhost:8000/health

5. **Setup RAG service**:
   ```bash
   cd rag
   pip install -r requirements.txt
   python -m uvicorn src.main:app --reload --port 8001
   ```
   RAG API: http://localhost:8001
   Health check: http://localhost:8001/health

### Environment Variables

Copy `.env.example` to `.env` in each service directory:

```bash
# Frontend (.env.local in /website)
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
NEXT_PUBLIC_RAG_API_URL=http://localhost:8001

# Backend (.env in /backend)
DATABASE_URL=postgresql://textbook:textbook_dev@localhost:5432/textbook_db
OPENAI_API_KEY=<your-key>
QDRANT_URL=http://localhost:6333

# RAG (.env in /rag)
OPENAI_API_KEY=<your-key>
QDRANT_URL=http://localhost:6333
```

## 📊 Tech Stack

| Layer | Technology | Deployment |
|-------|-----------|-----------|
| **Frontend** | React 18, Next.js 14, TypeScript, Tailwind CSS | Vercel |
| **Backend** | FastAPI, Python 3.11, SQLAlchemy, Better-Auth | Railway |
| **RAG** | Python, Qdrant, MiniLM embeddings, OpenAI | Railway |
| **Database** | PostgreSQL (Neon) + Qdrant vectors | Cloud managed |
| **CI/CD** | GitHub Actions | GitHub |

## 📈 Performance Targets

- **Chapter load**: < 2s (desktop), < 3s (mobile)
- **Chatbot response**: < 3 seconds
- **Urdu translation**: < 5s per chapter (cached)
- **Concurrent users**: 100+ without degradation
- **Uptime**: 99.5% during demo window

## 🧪 Testing

### Frontend
```bash
cd website
npm run test
npm run test:watch
```

### Backend
```bash
cd backend
pytest
pytest --cov
```

### RAG
```bash
cd rag
pytest
```

## 📦 Deployment

### Frontend → Vercel
```bash
npm run build
vercel deploy --prod
```

### Backend → Railway
```bash
docker build -t ai-textbook-backend:latest -f backend/Dockerfile .
railway up
```

### RAG → Railway
```bash
docker build -t ai-textbook-rag:latest -f rag/Dockerfile .
railway up
```

See [`DEPLOYMENT.md`](DEPLOYMENT.md) for detailed deployment steps.

## 📚 Documentation

- **Specification**: [`specs/001-textbook-generation/spec.md`](specs/001-textbook-generation/spec.md) — User stories, requirements, success criteria
- **Plan**: [`specs/001-textbook-generation/plan.md`](specs/001-textbook-generation/plan.md) — Architecture, phases, risk mitigation
- **Tasks**: [`specs/001-textbook-generation/tasks.md`](specs/001-textbook-generation/tasks.md) — 71 implementation tasks (Phase 1–8)
- **Constitution**: [`.specify/memory/constitution.md`](.specify/memory/constitution.md) — Core principles, governance, tech stack

## 📋 API Endpoints

### Chapters
- `GET /chapters` — List all chapters
- `GET /chapters/{id}` — Get full chapter content
- `POST /personalize` — Get personalized chapter

### Chat
- `POST /chat` — Ask chatbot question (grounded RAG)

### Auth
- `POST /auth/signup` — Create account with background
- `POST /auth/login` — Authenticate user
- `POST /auth/logout` — Logout

### Translations
- `POST /translate` — Translate chapter to Urdu

### Learning Tools
- `GET /summaries/{chapter_id}` — Get chapter summary
- `GET /quizzes/{chapter_id}` — Get chapter quiz

### Health
- `GET /health` — Service health check

See [`specs/001-textbook-generation/contracts/`](specs/001-textbook-generation/contracts/) for OpenAPI specs.

## 🎯 Success Criteria

### Specification (SC)
- ✅ SC-001: Chapters load < 2s (desktop) / < 3s (mobile)
- ✅ SC-002: Mobile responsive on 375px viewport
- ✅ SC-003: Total read < 45 minutes
- ✅ SC-004: Chatbot responds < 3s
- ✅ SC-005: 90% of responses cited
- ✅ SC-006: 90% in-scope accuracy
- ✅ SC-007: 100% out-of-scope refusals
- ✅ SC-008: Urdu < 5s (cached)
- ✅ SC-009: Urdu ≥ 4/5 quality
- ✅ SC-010: Personalization visible
- ✅ SC-011: 80% completion rate
- ✅ SC-012: 90% quiz accuracy
- ✅ SC-013: 100+ concurrent users
- ✅ SC-014: 99.5% uptime
- ✅ SC-015: Live URLs stable

## 📞 Support

For issues, questions, or contributions, please refer to the specification and implementation plan in the `specs/` directory.

## 📄 License

[Specify your license here]

---

**Built with ❤️ for learners of Physical AI & Humanoid Robotics**

**Constitution v1.0.0** | **Spec v1.0.0** | **Plan v1.0.0** | **Tasks v1.0.0**
# Book
