# AI-Native Textbook for Physical AI & Humanoid Robotics Constitution

<!-- 
Sync Impact Report
==================
- Version change: 0.0.1 → 1.0.0 (MAJOR: Initial constitution with 5 core principles)
- Added principles: AI-Native Design, Speed & Simplicity, User-First Implementation, Clean Architecture, Deployment-Ready Discipline
- Added sections: Technology Stack, Quality & Observability, Development Workflow
- Templates updated: spec-template.md, plan-template.md, tasks-template.md aligned with new principles
- PHR created: constitutional-design-ai-textbook (ID: phr-001)
-->

## Mission

Build a fully AI-native, interactive, intelligent textbook that teaches the Physical AI & Humanoid Robotics course. The product must be fast, simple, beautiful, and feel like a REAL AI-powered education platform - not just a book.

## Core Principles

### I. AI-Native Design

Every component must leverage AI to enhance learning:
- RAG chatbot answers ONLY from book content with citations
- Auto-generated summaries, quizzes, and learning boosters for each chapter
- Personalized chapter content based on learner background
- One-click Urdu translation via LLM integration
- All AI features MUST be grounded in textbook content; no hallucinations permitted

**Rationale**: The entire value proposition depends on seamless AI integration. AI must not be bolted-on—it is core to every user interaction.

### II. Speed & Simplicity

Build lean, readable, mobile-first always:
- Book readable in under 45 minutes (6–8 short chapters maximum)
- No extra animations beyond minimal useful motion
- No overly complex robotics code examples—education only
- UI/UX focused on clarity: minimal UI, fast-loading, zero bloat
- Every page targets users on low-end devices (phones)

**Rationale**: A textbook is about content delivery, not feature density. Speed and clarity directly improve learning outcomes and user satisfaction.

### III. User-First Implementation

Prioritize learner needs in task ordering:
- **P1**: Smooth textbook reading (foundational)
- **P2**: Functional RAG chatbot
- **P3**: Personalized content + translations
- **P4**: Summaries, quizzes, learning tools
- P1 must be complete before P2 starts. All P2 features must work before P3, etc.

**Rationale**: Each priority tier builds on the previous. Delivery is safer, faster, and users get value sooner.

### IV. Clean Architecture

Separate concerns cleanly across services:
- **Frontend** (`/website`): React/Next.js + Docusaurus. Read-only rendering of chapters. No heavy logic.
- **Backend** (`/backend`): FastAPI with modular services. REST API for auth, personalization, translations.
- **RAG Service** (`/rag`): Dedicated Python service. Handles embeddings, retrieval, grounding.
- **Agents** (`/agents`): Reusable skill automations for bonus scoring.
- All data persisted in Neon (PostgreSQL) + Qdrant (vectors).
- Clear folder structure: no sprawl, no cross-cutting concerns in a single directory.

**Rationale**: Modularity enables parallel work, independent testing, and future scaling. Each service has one job.

### V. Deployment-Ready Discipline

Every deliverable must be deployable end-to-end:
- Frontend → Vercel (serverless, zero-config)
- Backend → Railway (containers, auto-scaling)
- Vectors → Qdrant Cloud (managed SaaS)
- Database → Neon (managed PostgreSQL)
- All services MUST have health checks and structured logging
- All deployments must use free/cheap tiers to meet constraints
- Demo must be recordable in 90 seconds; live URLs must remain stable

**Rationale**: Deployment is not a final step—it is a gate. If it cannot be deployed continuously, the architecture is broken.

## Technology Stack

### Frontend

- **Framework**: React with Next.js (or Docusaurus 3+)
- **Styling**: Tailwind CSS (utility-first, fast)
- **State**: React Context or minimal SWR for data fetching
- **Deployment**: Vercel (auto-deploy from git)

### Backend

- **Framework**: FastAPI (Python 3.11+)
- **Database**: Neon (PostgreSQL, free tier supports 3 branches)
- **Auth**: Better-Auth (OAuth/email signup/login)
- **Logging**: Structured JSON logs to stdout
- **Deployment**: Railway (containers, auto-scaling, free tier available)

### RAG Pipeline

- **Embeddings**: MiniLM (lightweight, high quality)
- **Vector Store**: Qdrant (free-tier cloud or self-hosted)
- **LLM**: OpenAI GPT-4o mini (fast, low-cost) or Claude (via Anthropic API)
- **Chunking**: Sentence-level + sliding window (no naive splitting)
- **Retrieval**: Top-3 semantic + keyword fallback

### Deployment & Monitoring

- **CI/CD**: GitHub Actions (free)
- **Logging**: Structured logging to stdout; centraliz via Railway/Vercel built-in logs
- **Monitoring**: Health checks on all services; uptime monitoring via free tier

### Free Tier Constraints

- Neon: 1 project, 3 branches, 1 GB storage
- Qdrant: Free cloud tier or self-hosted Docker
- Vercel: 100 GB bandwidth, unlimited deployments
- Railway: $5 USD/month starter tier
- OpenAI: Pay-per-token (estimated $10–50 for hackathon scope)

## Quality & Observability

### Logging & Debugging

- **All services** MUST emit structured JSON logs to stdout
- **Key events** MUST be logged: auth attempts, RAG retrievals, translation requests, errors
- **No sensitive data** in logs (passwords, keys, full user data)
- **Log level** configurable: DEBUG, INFO, WARN, ERROR

### Testing

- **No mandatory test suite** for MVP (speed prioritized over coverage)
- **Manual testing required** before deployment: read chapters on mobile, ask chatbot questions, test translations
- **Smoke tests** on deployment: health checks, auth flow, chatbot grounding

### Error Handling

- **User-facing errors**: Clear, actionable messages in English + Urdu
- **System errors**: Log fully; show generic "Something went wrong" to user
- **Timeouts**: All API calls MUST have timeouts (5s frontend, 30s backend)

## Development Workflow

### Branch Strategy

- `main`: Always deployable. Gated by health checks.
- `develop`: Integration branch. Feature branches cut from here.
- Feature branches: `feature/<description>` for new work

### Review & Merge

- PRs MUST pass health checks (linting, type checking where applicable)
- All PRs MUST include description of what changed + how to test
- Merges MUST follow conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Suggested commit trailers: `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>`

### Phases & Gates

1. **Phase 1 (Setup)**: Project structure, dependencies, boilerplate
2. **Phase 2 (Foundational)**: Auth, database schema, RAG pipeline skeleton
3. **Phase 3 (MVP)**: Textbook chapters, chatbot working, demo-ready
4. **Phase 4 (Polish)**: Personalization, translations, refinements
5. **Gate before next phase**: Previous phase fully functional, tested, and deployable

## Non-Negotiable Constraints

- **Scope**: 6–8 chapters ONLY. No infinite content.
- **Mobile**: Must work on small screens. Test on 375px viewport.
- **Latency**: Chatbot response <3 seconds. Page load <2 seconds.
- **Cost**: Must stay on free/low-cost tiers.
- **Hallucination**: RAG MUST cite sources. No unsourced claims.
- **Urdu**: Translation MUST be high-quality. Not machine-only; consider human review if time allows.

## Governance

### Constitution Authority

This Constitution supersedes all prior documents, styles, and practices. It is the source of truth for this project.

### Amendment Process

1. Detect a decision that violates or conflicts with this Constitution
2. Document the conflict in an ADR (Architectural Decision Record) under `history/adr/`
3. Propose amendment(s) with clear rationale and impact assessment
4. Ratify via explicit approval (mark: "Ratified on YYYY-MM-DD")
5. Update version (MAJOR.MINOR.PATCH) according to semantic versioning
6. Re-run consistency checks across all dependent templates

### Compliance Review

- Every PR MUST verify it aligns with Core Principles (especially AI-Native, Speed & Simplicity, Clean Architecture)
- Every deployment MUST satisfy Deployment-Ready Discipline constraints (health checks, logging, free-tier compliance)
- Every user story MUST be independently testable and map to a priority tier (User-First Implementation)

### Guidance & Support

- For questions on implementation approach, see `.specify/templates/plan-template.md` for technical context gates
- For task breakdowns, see `.specify/templates/tasks-template.md` for phase & dependency structure
- For specification details, see `.specify/templates/spec-template.md` for user story & requirement format
- For PHR/ADR/checklist generation, see `.specify/commands/` for CLI commands

**Version**: 1.0.0 | **Ratified**: 2026-02-21 | **Last Amended**: 2026-02-21
