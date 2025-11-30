# Script to run tests locally with Docker (Windows)

Write-Host "Building test Docker image..." -ForegroundColor Green
docker build -t mern-chatbot-tests .

Write-Host "Running tests..." -ForegroundColor Green
docker run --rm `
  --network="host" `
  -e BASE_URL=http://localhost:5173 `
  -e BACKEND_URL=http://localhost:5000 `
  -e HEADLESS=true `
  -v "${PWD}/reports:/app/reports" `
  mern-chatbot-tests

Write-Host "Tests completed! Check reports/test_report.html for results." -ForegroundColor Green
