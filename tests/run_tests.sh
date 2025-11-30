#!/bin/bash
# Script to run tests locally with Docker

echo "Building test Docker image..."
docker build -t mern-chatbot-tests .

echo "Running tests..."
docker run --rm \
  --network="host" \
  -e BASE_URL=http://localhost:5173 \
  -e BACKEND_URL=http://localhost:5000 \
  -e HEADLESS=true \
  -v "$(pwd)/reports:/app/reports" \
  mern-chatbot-tests

echo "Tests completed! Check reports/test_report.html for results."
