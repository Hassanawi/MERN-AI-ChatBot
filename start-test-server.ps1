# Quick test script without Docker
# This runs a simple Python HTTP server on port 5174 for testing Selenium

Write-Host "Starting simple test server on http://localhost:5174..." -ForegroundColor Green
Write-Host "This is for testing Selenium tests only" -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
Write-Host ""

# Create a simple HTML page for testing
$testHtml = @"
<!DOCTYPE html>
<html>
<head>
    <title>MERN ChatBot - Test Mode</title>
</head>
<body>
    <h1>MERN AI ChatBot</h1>
    <p>Test server running...</p>
    <a href="/login">Login</a>
    <a href="/signup">Signup</a>
    <a href="/chat">Chat</a>
</body>
</html>
"@

# Save test HTML
$testHtml | Out-File -FilePath "test-server.html" -Encoding UTF8

# Start Python HTTP server
python -m http.server 5174

# Cleanup
Remove-Item "test-server.html" -ErrorAction SilentlyContinue
