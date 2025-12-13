#!/bin/bash
# Test script for Supabase Stage 1 implementation
# Usage: ./test_supabase_stage1.sh <PROJECT_REF> <ANON_KEY> <ACCESS_TOKEN>

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -ne 3 ]; then
    echo -e "${RED}Usage: $0 <PROJECT_REF> <ANON_KEY> <ACCESS_TOKEN>${NC}"
    echo "Example: $0 abcdefghijk your-anon-key your-access-token"
    exit 1
fi

PROJECT_REF=$1
ANON_KEY=$2
ACCESS_TOKEN=$3
BASE_URL="https://${PROJECT_REF}.supabase.co/rest/v1/readings"

echo "======================================"
echo "Supabase Stage 1 Testing"
echo "======================================"
echo ""

# Test 1: POST with anon key (ESP32 simulation)
echo -e "${YELLOW}Test 1: POST reading with anon key (ESP32 simulation)${NC}"
echo "Expected: 201 Created"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{
    "device_id": "tea_room_01",
    "temperature": 25.5,
    "humidity": 62.0
  }')

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "201" ]; then
    echo -e "${GREEN}✓ Test 1 PASSED: HTTP $HTTP_CODE${NC}"
else
    echo -e "${RED}✗ Test 1 FAILED: HTTP $HTTP_CODE${NC}"
    echo "Response: $BODY"
fi
echo ""

# Wait a bit for data to be written
sleep 1

# Test 2: GET with anon key (should fail or return empty based on RLS)
echo -e "${YELLOW}Test 2: GET readings with anon key (should be restricted)${NC}"
echo "Expected: 200 but empty result or 401/403"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "$BASE_URL?select=*" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ] && [ "$BODY" = "[]" ]; then
    echo -e "${GREEN}✓ Test 2 PASSED: HTTP $HTTP_CODE with empty result (RLS working)${NC}"
elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    echo -e "${GREEN}✓ Test 2 PASSED: HTTP $HTTP_CODE (Access denied as expected)${NC}"
else
    echo -e "${YELLOW}⚠ Test 2 WARNING: HTTP $HTTP_CODE${NC}"
    echo "Response: $BODY"
fi
echo ""

# Test 3: GET with authenticated token (should succeed)
echo -e "${YELLOW}Test 3: GET readings with authenticated token${NC}"
echo "Expected: 200 with data"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X GET "$BASE_URL?select=*&limit=5&order=created_at.desc" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "200" ] && [ "$BODY" != "[]" ]; then
    echo -e "${GREEN}✓ Test 3 PASSED: HTTP $HTTP_CODE${NC}"
    echo "Latest readings:"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
elif [ "$HTTP_CODE" = "200" ] && [ "$BODY" = "[]" ]; then
    echo -e "${YELLOW}⚠ Test 3 WARNING: HTTP $HTTP_CODE but no data found${NC}"
    echo "This might be expected if no data was inserted yet"
else
    echo -e "${RED}✗ Test 3 FAILED: HTTP $HTTP_CODE${NC}"
    echo "Response: $BODY"
fi
echo ""

# Test 4: Insert multiple test data
echo -e "${YELLOW}Test 4: Batch insert test data${NC}"
echo "Inserting 3 test readings..."
echo ""

for i in {1..3}; do
    TEMP=$(awk "BEGIN {print 24 + $i * 0.5}")
    HUMID=$((60 + i * 2))

    curl -s -X POST "$BASE_URL" \
      -H "apikey: $ANON_KEY" \
      -H "Authorization: Bearer $ANON_KEY" \
      -H "Content-Type: application/json" \
      -H "Prefer: return=minimal" \
      -d "{
        \"device_id\": \"tea_room_01\",
        \"temperature\": $TEMP,
        \"humidity\": $HUMID
      }" > /dev/null

    echo "  Inserted: temp=${TEMP}°C, humidity=${HUMID}%"
    sleep 0.5
done

echo -e "${GREEN}✓ Test 4 COMPLETED${NC}"
echo ""

# Test 5: Validate data constraints - Invalid temperature (too high)
echo -e "${YELLOW}Test 5: POST with invalid temperature (> 100)${NC}"
echo "Expected: 400 or 403 (rejected by RLS policy)"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{
    "device_id": "tea_room_01",
    "temperature": 150.0,
    "humidity": 62.0
  }')

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "403" ]; then
    echo -e "${GREEN}✓ Test 5 PASSED: HTTP $HTTP_CODE (Invalid data rejected)${NC}"
else
    echo -e "${RED}✗ Test 5 FAILED: HTTP $HTTP_CODE (Expected 400/403)${NC}"
    echo "Response: $BODY"
fi
echo ""

# Test 6: Validate data constraints - Invalid humidity (negative)
echo -e "${YELLOW}Test 6: POST with invalid humidity (< 0)${NC}"
echo "Expected: 400 or 403 (rejected by RLS policy)"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{
    "device_id": "tea_room_01",
    "temperature": 25.0,
    "humidity": -10.0
  }')

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "403" ]; then
    echo -e "${GREEN}✓ Test 6 PASSED: HTTP $HTTP_CODE (Invalid data rejected)${NC}"
else
    echo -e "${RED}✗ Test 6 FAILED: HTTP $HTTP_CODE (Expected 400/403)${NC}"
    echo "Response: $BODY"
fi
echo ""

# Test 7: Validate data constraints - Empty device_id
echo -e "${YELLOW}Test 7: POST with empty device_id${NC}"
echo "Expected: 400 or 403 (rejected by RLS policy)"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST "$BASE_URL" \
  -H "apikey: $ANON_KEY" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=minimal" \
  -d '{
    "device_id": "",
    "temperature": 25.0,
    "humidity": 62.0
  }')

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE")

if [ "$HTTP_CODE" = "400" ] || [ "$HTTP_CODE" = "403" ]; then
    echo -e "${GREEN}✓ Test 7 PASSED: HTTP $HTTP_CODE (Invalid data rejected)${NC}"
else
    echo -e "${RED}✗ Test 7 FAILED: HTTP $HTTP_CODE (Expected 400/403)${NC}"
    echo "Response: $BODY"
fi
echo ""

# Summary
echo "======================================"
echo -e "${GREEN}Testing Complete!${NC}"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Verify data in Supabase Dashboard"
echo "2. Test Realtime subscription from iOS app"
echo "3. Proceed with ESP32 and iOS implementation"

