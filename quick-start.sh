#!/bin/bash
# Quick Start Script for Linux/Mac

echo "🚀 Secure Web App Pipeline - Quick Start"
echo "========================================="
echo ""

# Check if Docker is running
echo "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✓ Docker is running"
echo ""

# Build Docker image
echo "Building Docker image..."
cd app
if ! docker build -t secure-webapp:local .; then
    echo "✗ Docker build failed"
    exit 1
fi
echo "✓ Docker image built successfully"
echo ""

# Start application
echo "Starting application..."
if ! docker run -d --name secure-webapp-test -p 5000:5000 secure-webapp:local; then
    echo "✗ Failed to start container"
    exit 1
fi
echo "✓ Application started"
echo ""

# Wait for app to be ready
echo "Waiting for application to be ready..."
sleep 5

# Test the application
echo ""
echo "Testing application..."
if curl -f http://localhost:5000/health > /dev/null 2>&1; then
    echo "✓ Application is healthy!"
    echo ""
    echo "Application is running at: http://localhost:5000"
    echo ""
    echo "Available endpoints:"
    echo "  - http://localhost:5000/          (Home)"
    echo "  - http://localhost:5000/health    (Health Check)"
    echo "  - http://localhost:5000/api/tasks (API)"
    echo ""
    echo "To stop the application, run:"
    echo "  docker stop secure-webapp-test"
    echo "  docker rm secure-webapp-test"
else
    echo "✗ Application is not responding"
    echo "Check logs with: docker logs secure-webapp-test"
fi

echo ""
echo "Next Steps:"
echo "1. Review SETUP.md for full deployment guide"
echo "2. Configure AWS credentials"
echo "3. Deploy to AWS with Terraform"
echo "4. Set up GitHub Actions for CI/CD"
