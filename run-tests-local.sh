#!/bin/bash
# Quick test runner for local development

echo "=================================="
echo "MERN ChatBot - Test Runner"
echo "=================================="

# Check if application is running
echo ""
echo "Checking if application is running..."
if ! docker ps | grep -q "mern-chatbot"; then
    echo "⚠️  Application containers not found!"
    echo "Starting application with docker-compose-ci.yml..."
    docker-compose -f docker-compose-ci.yml up -d
    echo "Waiting for services to start (30 seconds)..."
    sleep 30
else
    echo "✅ Application containers are running"
fi

# Navigate to tests directory
cd tests || exit

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo ""
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo ""
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo ""
echo "Installing dependencies..."
pip install -q -r requirements.txt

# Run tests
echo ""
echo "=================================="
echo "Running Selenium Tests"
echo "=================================="
pytest test_chatbot.py -v --html=reports/test_report.html --self-contained-html

# Check test result
if [ $? -eq 0 ]; then
    echo ""
    echo "=================================="
    echo "✅ All tests passed!"
    echo "=================================="
    echo ""
    echo "📊 Test report: tests/reports/test_report.html"
    echo "📸 Screenshots: tests/reports/screenshots/"
else
    echo ""
    echo "=================================="
    echo "❌ Some tests failed!"
    echo "=================================="
    echo ""
    echo "📊 Check test report: tests/reports/test_report.html"
    echo "📸 Check screenshots: tests/reports/screenshots/"
fi

# Deactivate virtual environment
deactivate

echo ""
echo "=================================="
echo "Test execution completed!"
echo "=================================="
