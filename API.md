# API Documentation

Complete REST API reference for the AI-Native Textbook system.

## Base URLs

- **Development**: `http://localhost:8000`
- **Production**: `https://api.textbook.railway.app`
- **RAG Service**: `https://rag.textbook.railway.app`

---

## Authentication

JWT Bearer token authentication. Include in header:
```
Authorization: Bearer <access_token>
```

### Auth Endpoints

#### POST /auth/signup
Register a new user.

**Request:**
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "SecurePassword123!",
  "full_name": "Full Name",
  "background": "student"
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username",
    "background": "student"
  }
}
```

#### POST /auth/login
Authenticate user.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": { ... }
}
```

#### POST /auth/refresh
Refresh access token using refresh token.

**Request:**
```json
{
  "refresh_token": "eyJ..."
}
```

**Response:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ..."
}
```

---

## Chapter Management

### GET /chapters
List all chapters.

**Response:**
```json
[
  {
    "id": "01-introduction",
    "title": "Introduction to Physical AI",
    "order": 1,
    "word_count": 1200,
    "read_time_minutes": 4
  },
  ...
]
```

### GET /chapters/{id}
Get chapter content.

**Response:**
```json
{
  "id": "01-introduction",
  "title": "Introduction to Physical AI",
  "content": "# Introduction\n\n...",
  "word_count": 1200,
  "read_time_minutes": 4
}
```

### GET /chapters/search?q={query}
Search chapters by text.

**Response:**
```json
[
  {
    "id": "01-introduction",
    "title": "Introduction to Physical AI",
    "excerpt": "Physical AI is the field of...",
    "relevance": 0.95
  }
]
```

### GET /chapters/stats
Get textbook statistics.

**Response:**
```json
{
  "total_chapters": 8,
  "total_words": 9500,
  "total_read_time_minutes": 42,
  "chapters": [...]
}
```

---

## Chat & Q&A

### POST /chat
Ask a question to the RAG chatbot.

**Request:**
```json
{
  "question": "What is humanoid robotics?",
  "chapter_id": "02-humanoid-fundamentals"
}
```

**Response:**
```json
{
  "question": "What is humanoid robotics?",
  "answer": "Humanoid robotics is the field of designing and building robots that mimic human form and movement...",
  "citations": [
    {
      "chapter": "02-humanoid-fundamentals",
      "chunk_index": 0,
      "score": 0.92
    }
  ],
  "is_grounded": true,
  "confidence": 0.95,
  "timestamp": "2026-02-21T13:53:40Z"
}
```

### GET /chat/history
Get user's chat history (requires auth).

**Response:**
```json
[
  {
    "id": 1,
    "question": "What is humanoid robotics?",
    "answer": "...",
    "citations": [...],
    "created_at": "2026-02-21T13:53:40Z"
  },
  ...
]
```

### DELETE /chat/history/{id}
Delete a chat entry (requires auth).

---

## Personalization

### GET /personalize/backgrounds
List available background levels.

**Response:**
```json
[
  {
    "background": "student",
    "description": "High school or early university student with basic physics knowledge"
  },
  {
    "background": "intermediate",
    "description": "CS/Engineering student or professional with 1-2 years experience"
  },
  {
    "background": "expert",
    "description": "Researcher or experienced engineer with 5+ years in the field"
  },
  {
    "background": "general",
    "description": "General audience with no specific background"
  }
]
```

### POST /personalize/chapter
Get personalized chapter content.

**Request:**
```json
{
  "chapter_id": 1,
  "background": "student",
  "force_regenerate": false
}
```

**Response:**
```json
{
  "chapter_id": 1,
  "background": "student",
  "content": "# Introduction\n\nSimplified version for student background..."
}
```

---

## Translation

### GET /translate/languages
List supported languages.

**Response:**
```json
[
  {
    "code": "ur",
    "name": "Urdu"
  },
  {
    "code": "es",
    "name": "Spanish"
  },
  {
    "code": "fr",
    "name": "French"
  },
  ...
]
```

### POST /translate/chapter
Get translated chapter.

**Request:**
```json
{
  "chapter_id": 1,
  "language": "ur",
  "force_regenerate": false
}
```

**Response:**
```json
{
  "chapter_id": 1,
  "language": "ur",
  "content": "# تعارف\n\nمہمان پرائی مصنوعی ذہانت کا میدان ہے..."
}
```

---

## Summaries

### GET /summaries/chapters/{id}
Get chapter summary.

**Response:**
```json
{
  "chapter_id": 1,
  "short_summary": "This chapter introduces the concepts of Physical AI and humanoid robotics, defining the field and its key applications.",
  "key_points": [
    "Physical AI is the intersection of AI and robotics",
    "Humanoid robots mimic human form and movement",
    "Applications range from manufacturing to healthcare"
  ]
}
```

### GET /summaries/all
Get all chapter summaries.

---

## Quizzes

### GET /quizzes/chapters/{id}
Get chapter quiz.

**Response:**
```json
{
  "chapter_id": 1,
  "difficulty": "medium",
  "questions": [
    {
      "question": "What is humanoid robotics?",
      "options": [
        "A) Robots that look like humans",
        "B) AI systems that learn like humans",
        "C) Robots designed to perform human tasks",
        "D) All of the above"
      ],
      "correct_answer": "D",
      "explanation": "Humanoid robotics combines physical form, AI, and task capabilities."
    },
    ...
  ]
}
```

### POST /quizzes/chapters/{id}/submit
Submit and grade quiz answers.

**Request:**
```json
{
  "0": "D",
  "1": "B",
  ...
}
```

**Response:**
```json
{
  "score": 7,
  "total": 8,
  "percentage": 87.5,
  "feedback": [
    {
      "question_index": 0,
      "is_correct": true,
      "explanation": "..."
    },
    ...
  ]
}
```

---

## Health & Status

### GET /health
Health check.

**Response:**
```json
{
  "status": "healthy"
}
```

### GET /ready
Readiness check (database + services).

**Response:**
```json
{
  "status": "ready",
  "database": "connected",
  "cache": "available"
}
```

---

## Error Responses

All errors follow this format:

```json
{
  "detail": "Error message describing what went wrong",
  "status_code": 400
}
```

### Status Codes

- `200` - OK
- `201` - Created
- `400` - Bad request (invalid input)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not found
- `500` - Internal server error
- `503` - Service unavailable

---

## Rate Limiting

- **Chat endpoint**: 10 requests per minute per user
- **Auth endpoints**: 5 requests per minute per IP
- **Other endpoints**: 100 requests per minute per user

---

## Examples

### Complete User Flow (cURL)

```bash
# 1. Sign up
curl -X POST http://localhost:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "username": "testuser",
    "password": "Test123!",
    "background": "student"
  }'

# Response: { "access_token": "...", "refresh_token": "..." }
# Save: TOKEN=<access_token>

# 2. Get chapters
curl http://localhost:8000/chapters

# 3. Get chapter content
curl http://localhost:8000/chapters/1

# 4. Ask a question
curl -X POST http://localhost:8000/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What is humanoid robotics?",
    "chapter_id": "02-humanoid-fundamentals"
  }'

# 5. Get chat history
curl http://localhost:8000/chat/history \
  -H "Authorization: Bearer $TOKEN"

# 6. Personalize content
curl -X POST http://localhost:8000/personalize/chapter \
  -H "Content-Type: application/json" \
  -d '{
    "chapter_id": 1,
    "background": "intermediate"
  }'

# 7. Translate chapter
curl -X POST http://localhost:8000/translate/chapter \
  -H "Content-Type: application/json" \
  -d '{
    "chapter_id": 1,
    "language": "ur"
  }'

# 8. Get summary
curl http://localhost:8000/summaries/chapters/1

# 9. Get quiz
curl http://localhost:8000/quizzes/chapters/1

# 10. Submit quiz
curl -X POST http://localhost:8000/quizzes/chapters/1/submit \
  -H "Content-Type: application/json" \
  -d '{"0":"D","1":"B","2":"A"}'
```

---

## Postman Collection

Import the Postman collection for easier testing:
- File: `postman-collection.json` (to be created)
- Base URL: `{{base_url}}`
- Variable: `{{token}}`

---

## Support

For API issues:
1. Check status at `GET /health`
2. Review error message detail
3. Check logs at `https://railway.app`
4. Open issue on GitHub

---

**Last Updated**: 2026-02-21  
**API Version**: 1.0.0  
**Status**: Production Ready
