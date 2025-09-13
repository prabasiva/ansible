#!/bin/bash
# Docker fix script for macOS using Colima
set -e

echo "🔧 Docker/Colima Fix Script for macOS"
echo "======================================"

# Function to wait for Docker to be ready
wait_for_docker() {
    local max_attempts=30
    local attempt=1
    
    echo "⏳ Waiting for Docker to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker info >/dev/null 2>&1; then
            echo "✅ Docker is ready!"
            return 0
        fi
        
        echo "   Attempt $attempt/$max_attempts - Docker not ready yet..."
        sleep 2
        ((attempt++))
    done
    
    echo "❌ Docker failed to start within $max_attempts attempts"
    return 1
}

# Check if Colima and Docker are installed
if ! command -v colima >/dev/null 2>&1 || ! command -v docker >/dev/null 2>&1; then
    echo "❌ Colima and/or Docker are not installed"
    echo "Installing Colima and Docker..."
    
    if command -v brew >/dev/null 2>&1; then
        echo "   Using Homebrew to install Colima and Docker..."
        brew install colima docker
    else
        echo "   Please install Homebrew first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
fi

# Check if Colima is running
if ! colima status | grep -q "Running" 2>/dev/null; then
    echo "🚀 Starting Colima..."
    colima start --cpu 4 --memory 8
    
    # Wait for Docker to be ready
    wait_for_docker
else
    echo "✅ Colima is already running"
    
    # Still check if it's responsive
    if ! docker info >/dev/null 2>&1; then
        echo "⚠️  Colima is running but Docker daemon is not responsive"
        echo "   Restarting Colima..."
        colima restart
        wait_for_docker
    fi
fi

# Test Docker functionality
echo "🧪 Testing Docker functionality..."

if docker run --rm hello-world >/dev/null 2>&1; then
    echo "✅ Docker is working correctly!"
else
    echo "❌ Docker test failed"
    echo "   Trying to fix common issues..."
    
    # Clean up any stuck containers
    echo "   Cleaning up Docker resources..."
    docker system prune -f >/dev/null 2>&1 || true
    
    # Try the test again
    if docker run --rm hello-world >/dev/null 2>&1; then
        echo "✅ Docker is now working!"
    else
        echo "❌ Docker is still not working"
        echo "   Please try restarting Docker Desktop manually"
        exit 1
    fi
fi

# Check Colima resources
echo "📊 Checking Colima resources..."
colima_status=$(colima status 2>/dev/null)

if echo "$colima_status" | grep -q "Memory"; then
    memory=$(echo "$colima_status" | grep "Memory" | awk '{print $2}')
    echo "   Available Memory: $memory"
    
    # Extract memory value for comparison
    memory_gb=$(echo "$memory" | sed 's/GiB//' | awk '{print int($1)}')
    
    if [ "$memory_gb" -lt 4 ]; then
        echo "⚠️  Warning: Colima has less than 4GB memory allocated"
        echo "   For better performance, restart with: colima stop && colima start --cpu 4 --memory 8"
    fi
fi

# Test network connectivity
echo "🌐 Testing network connectivity..."
if docker run --rm alpine:latest wget -q --spider http://google.com >/dev/null 2>&1; then
    echo "✅ Network connectivity is working"
else
    echo "⚠️  Network connectivity issue detected"
    echo "   This might affect downloading container images"
fi

echo ""
echo "🎉 Docker/Colima setup verification complete!"
echo ""
echo "Next steps:"
echo "1. Run 'make test-multi' to test the Ansible Molecule environment"
echo "2. If issues persist, check the TROUBLESHOOTING.md file"
echo "3. To adjust Colima resources: colima stop && colima start --cpu 4 --memory 8 --disk 60"
echo ""

# Show current versions
echo "📋 Version Information:"
docker version --format 'Client: {{.Client.Version}}' 2>/dev/null
docker version --format 'Server: {{.Server.Version}}' 2>/dev/null
echo "Colima: $(colima version 2>/dev/null)"
echo ""