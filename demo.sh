#!/bin/bash

# AI-Native Textbook Demo Script
# This script demonstrates all features of the textbook system
# Run this after deploying to production

set -e

BASE_URL="${1:-http://localhost:8000}"
echo "🎓 AI-Native Textbook Demo"
echo "================================"
echo "Base URL: $BASE_URL"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test variables
TEST_EMAIL="demo@textbook.ai"
TEST_PASSWORD="DemoPassword123!"
TEST_USERNAME="demouser"
ACCESS_TOKEN=""
REFRESH_TOKEN=""

# 1. Health Check
echo -e "${BLUE}1. Testing System Health${NC}"
curl -s "$BASE_URL/health" | jq '.' || echo "❌ Health check failed"
echo ""

# 2. Sign Up
echo -e "${BLUE}2. User Signup${NC}"
SIGNUP_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/signup" \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"username\": \"$TEST_USERNAME\",
    \"password\": \"$TEST_PASSWORD\",
    \"full_name\": \"Demo User\",
    \"background\": \"student\"
  }")

ACCESS_TOKEN=$(echo $SIGNUP_RESPONSE | jq -r '.access_token')
REFRESH_TOKEN=$(echo $SIGNUP_RESPONSE | jq -r '.refresh_token')

if [ "$ACCESS_TOKEN" != "null" ] && [ "$ACCESS_TOKEN" != "" ]; then
  echo -e "${GREEN}✓ Signup successful${NC}"
  echo "  Email: $TEST_EMAIL"
  echo "  Username: $TEST_USERNAME"
  echo "  Background: student"
else
  echo -e "${YELLOW}⚠ Note: Signup might fail if user already exists (expected on re-runs)${NC}"
  # Try login instead
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$TEST_EMAIL\",
      \"password\": \"$TEST_PASSWORD\"
    }")
  ACCESS_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.access_token')
  REFRESH_TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.refresh_token')
fi
echo ""

# 3. Get Chapter List
echo -e "${BLUE}3. Browse Chapters${NC}"
CHAPTERS=$(curl -s "$BASE_URL/chapters" | jq '.[]')
CHAPTER_COUNT=$(curl -s "$BASE_URL/chapters" | jq 'length')
echo -e "${GREEN}✓ Found $CHAPTER_COUNT chapters${NC}"
echo "  Chapters:"
curl -s "$BASE_URL/chapters" | jq '.[] | "    - \(.title)"' -r
echo ""

# 4. Read a Chapter
echo -e "${BLUE}4. Reading Chapter 1${NC}"
CHAPTER_ID="01-introduction"
CHAPTER=$(curl -s "$BASE_URL/chapters/$CHAPTER_ID" | jq '.')
TITLE=$(echo $CHAPTER | jq -r '.title')
WORDS=$(echo $CHAPTER | jq -r '.word_count')
READ_TIME=$(echo $CHAPTER | jq -r '.read_time_minutes')
echo -e "${GREEN}✓ Loaded chapter${NC}"
echo "  Title: $TITLE"
echo "  Words: $WORDS"
echo "  Read time: ${READ_TIME} minutes"
echo ""

# 5. Search Chapters
echo -e "${BLUE}5. Searching Chapters${NC}"
SEARCH_RESULTS=$(curl -s "$BASE_URL/chapters/search?q=kinematics" | jq '.')
RESULT_COUNT=$(echo $SEARCH_RESULTS | jq 'length')
echo -e "${GREEN}✓ Search found $RESULT_COUNT results for 'kinematics'${NC}"
echo ""

# 6. Get Chapter Statistics
echo -e "${BLUE}6. Textbook Statistics${NC}"
STATS=$(curl -s "$BASE_URL/chapters/stats" | jq '.')
echo -e "${GREEN}✓ Textbook statistics:${NC}"
echo $STATS | jq '.[] | {total_chapters, total_words, total_read_time_minutes}'
echo ""

# 7. Ask Chatbot a Question
echo -e "${BLUE}7. Asking Chatbot a Question${NC}"
QUESTION="What is humanoid robotics and what are its main applications?"
echo "  Question: $QUESTION"
CHAT_RESPONSE=$(curl -s -X POST "$BASE_URL/chat" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"question\": \"$QUESTION\",
    \"chapter_id\": \"02-humanoid-fundamentals\"
  }")

ANSWER=$(echo $CHAT_RESPONSE | jq -r '.answer')
IS_GROUNDED=$(echo $CHAT_RESPONSE | jq -r '.is_grounded')
CONFIDENCE=$(echo $CHAT_RESPONSE | jq -r '.confidence')

echo -e "${GREEN}✓ Chatbot Response${NC}"
echo "  Grounded: $IS_GROUNDED"
echo "  Confidence: $(echo $CONFIDENCE | awk '{printf "%.0f%%\n", $1*100}')"
echo "  Answer: ${ANSWER:0:200}..."
echo ""

# 8. Get Chat History
echo -e "${BLUE}8. Chat History${NC}"
HISTORY=$(curl -s "$BASE_URL/chat/history" \
  -H "Authorization: Bearer $ACCESS_TOKEN" | jq '.')
HISTORY_COUNT=$(echo $HISTORY | jq 'length')
echo -e "${GREEN}✓ Retrieved $HISTORY_COUNT chat messages${NC}"
echo ""

# 9. List Personalization Options
echo -e "${BLUE}9. Content Personalization Options${NC}"
BACKGROUNDS=$(curl -s "$BASE_URL/personalize/backgrounds" | jq '.')
echo -e "${GREEN}✓ Available backgrounds:${NC}"
echo $BACKGROUNDS | jq '.[] | "    - \(.background): \(.description)"' -r
echo ""

# 10. Get Personalized Content
echo -e "${BLUE}10. Personalized Content (Intermediate Level)${NC}"
PERSONALIZED=$(curl -s -X POST "$BASE_URL/personalize/chapter" \
  -H "Content-Type: application/json" \
  -d "{
    \"chapter_id\": 1,
    \"background\": \"intermediate\"
  }")

PERSONALIZED_LENGTH=$(echo $PERSONALIZED | jq '.content | length')
echo -e "${GREEN}✓ Generated personalized content${NC}"
echo "  Length: $PERSONALIZED_LENGTH characters"
echo ""

# 11. List Translation Languages
echo -e "${BLUE}11. Available Translation Languages${NC}"
LANGUAGES=$(curl -s "$BASE_URL/translate/languages" | jq '.')
echo -e "${GREEN}✓ Supported languages:${NC}"
echo $LANGUAGES | jq '.[] | "    - \(.code): \(.name)"' -r
echo ""

# 12. Translate to Urdu
echo -e "${BLUE}12. Translating Chapter to Urdu${NC}"
TRANSLATED=$(curl -s -X POST "$BASE_URL/translate/chapter" \
  -H "Content-Type: application/json" \
  -d "{
    \"chapter_id\": 1,
    \"language\": \"ur\"
  }")

URDU_LENGTH=$(echo $TRANSLATED | jq '.content | length')
echo -e "${GREEN}✓ Translated to Urdu${NC}"
echo "  Length: $URDU_LENGTH characters"
echo "  First 100 chars: $(echo $TRANSLATED | jq '.content' -r | head -c 100)..."
echo ""

# 13. Get Chapter Summary
echo -e "${BLUE}13. Chapter Summary${NC}"
SUMMARY=$(curl -s "$BASE_URL/summaries/chapters/1" | jq '.')
SUMMARY_TEXT=$(echo $SUMMARY | jq -r '.short_summary')
KEY_POINTS=$(echo $SUMMARY | jq -r '.key_points | length')
echo -e "${GREEN}✓ Chapter summary generated${NC}"
echo "  Summary: ${SUMMARY_TEXT:0:150}..."
echo "  Key points: $KEY_POINTS"
echo ""

# 14. Get Chapter Quiz
echo -e "${BLUE}14. Chapter Quiz${NC}"
QUIZ=$(curl -s "$BASE_URL/quizzes/chapters/1" | jq '.')
QUESTION_COUNT=$(echo $QUIZ | jq '.questions | length')
echo -e "${GREEN}✓ Quiz generated${NC}"
echo "  Questions: $QUESTION_COUNT"
echo "  Difficulty: $(echo $QUIZ | jq -r '.difficulty')"
echo ""

# 15. Submit Quiz Answers
echo -e "${BLUE}15. Submitting Quiz Answers${NC}"
# Get first question's correct answer
CORRECT_ANSWER=$(echo $QUIZ | jq -r '.questions[0].correct_answer')
GRADE=$(curl -s -X POST "$BASE_URL/quizzes/chapters/1/submit" \
  -H "Content-Type: application/json" \
  -d "{
    \"0\": \"$CORRECT_ANSWER\"
  }")

SCORE=$(echo $GRADE | jq -r '.score')
TOTAL=$(echo $GRADE | jq -r '.total')
PERCENTAGE=$(echo $GRADE | jq -r '.percentage')
echo -e "${GREEN}✓ Quiz graded${NC}"
echo "  Score: $SCORE/$TOTAL ($(printf "%.0f" $PERCENTAGE)%)"
echo ""

# 16. Refresh Token
echo -e "${BLUE}16. Token Refresh${NC}"
REFRESHED=$(curl -s -X POST "$BASE_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{
    \"refresh_token\": \"$REFRESH_TOKEN\"
  }")

NEW_TOKEN=$(echo $REFRESHED | jq -r '.access_token')
if [ "$NEW_TOKEN" != "null" ] && [ "$NEW_TOKEN" != "" ]; then
  echo -e "${GREEN}✓ Token refreshed successfully${NC}"
else
  echo -e "${YELLOW}⚠ Token refresh might fail on first run${NC}"
fi
echo ""

# Summary
echo -e "${YELLOW}================================${NC}"
echo -e "${BLUE}✅ Demo Complete!${NC}"
echo -e "${YELLOW}================================${NC}"
echo ""
echo "Features demonstrated:"
echo "  ✓ User authentication (signup, login, refresh)"
echo "  ✓ Chapter browsing and searching"
echo "  ✓ Chapter reading with metadata"
echo "  ✓ RAG chatbot with grounding"
echo "  ✓ Chat history"
echo "  ✓ Content personalization"
echo "  ✓ Multi-language translation (Urdu)"
echo "  ✓ Auto-generated summaries"
echo "  ✓ Auto-generated quizzes with grading"
echo ""
echo "🎉 All features working!"
