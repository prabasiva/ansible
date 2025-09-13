# 🛠️ Troubleshooting Guide

## Docker Connection Issues

### Problem: `FileNotFoundError` when running Molecule tests

**Error Message:**
```
docker.errors.DockerException: Error while fetching server API version: ('Connection aborted.', FileNotFoundError(2, 'No such file or directory'))
```

### Solution for macOS with Colima:

1. **Install and Start Colima:**
   ```bash
   # Install Colima and Docker CLI via Homebrew
   brew install colima docker
   
   # Start Colima with sufficient resources
   colima start --cpu 4 --memory 8
   ```

2. **Verify Docker is running:**
   ```bash
   docker info
   docker ps
   ```

3. **If Colima is already installed but not running:**
   ```bash
   # Check Colima status
   colima status
   
   # Start Colima if stopped
   colima start
   ```

4. **Configure Colima for better performance:**
   ```bash
   # Start with more resources (adjust as needed)
   colima start --cpu 4 --memory 8 --disk 60
   
   # Or edit default profile
   colima start --edit
   ```

### Quick Fix Commands:

```bash
# 1. Install Colima (if not installed)
brew install colima docker

# 2. Start Colima
colima start --cpu 4 --memory 8

# 3. Verify Docker is working
docker run hello-world

# 4. Now run your Molecule test
make test-multi
```

## Alternative Testing Without Multi-Host

If you continue having Docker issues, you can test individual components:

```bash
# Test syntax only
make syntax

# Test Ansible playbooks directly (without containers)
ansible-playbook --syntax-check playbooks/site.yml -i inventory/hosts.yml

# Test individual roles with Molecule (single container)
make test  # Uses default scenario with single container
```

## Colima Status Check

```bash
# Check if Colima is running
colima status

# Check Docker daemon
docker version

# List Colima profiles
colima list
```

## Common Colima Issues on macOS

### Issue 1: Colima not starting
**Solution:**
```bash
# Stop and restart Colima
colima stop
colima start --cpu 4 --memory 8

# If that fails, delete and recreate
colima delete
colima start --cpu 4 --memory 8
```

### Issue 2: Resource limits
**Solution:**
```bash
# Stop Colima and restart with more resources
colima stop
colima start --cpu 4 --memory 8 --disk 60

# Check current resource allocation
colima status
```

### Issue 3: Network issues
**Solution:**
```bash
# Restart Colima to reset networking
colima restart

# Reset Docker networks
docker network prune -f
```

## Testing Without Docker (Ansible Only)

If Docker continues to cause issues, you can still validate the Ansible code:

```bash
# Install ansible-lint
pip install ansible-lint

# Lint all roles and playbooks
ansible-lint roles/ playbooks/

# Check syntax
ansible-playbook --syntax-check playbooks/site.yml -i inventory/hosts.yml
ansible-playbook --syntax-check playbooks/development.yml -i inventory/hosts.yml
ansible-playbook --syntax-check playbooks/production.yml -i inventory/hosts.yml

# Validate inventory
ansible-inventory --list -i inventory/hosts.yml
```

## Quick Colima Status Script

Save this as `check-colima.sh`:

```bash
#!/bin/bash

echo "🔍 Checking Colima status..."

# Check if Colima is installed
if ! command -v colima >/dev/null 2>&1; then
    echo "❌ Colima is not installed"
    echo "   Installing Colima..."
    brew install colima docker
fi

# Check if Colima is running
if colima status | grep -q "Running"; then
    echo "✅ Colima is running"
else
    echo "❌ Colima is not running"
    echo "   Starting Colima..."
    colima start --cpu 4 --memory 8
fi

# Check Docker daemon
if docker info >/dev/null 2>&1; then
    echo "✅ Docker daemon is accessible"
    echo "   Docker version: $(docker --version)"
    echo "   Colima version: $(colima version)"
else
    echo "❌ Cannot connect to Docker daemon"
    echo "   Please ensure Colima is fully started"
    exit 1
fi

# Test basic Docker functionality
if docker run --rm hello-world >/dev/null 2>&1; then
    echo "✅ Docker is working correctly"
else
    echo "❌ Docker test failed"
    exit 1
fi

echo "🎉 Docker with Colima is ready for Molecule testing!"
```

```bash
# Make executable and run
chmod +x check-colima.sh
./check-colima.sh
```

## Updated Makefile Target

I'll add a Docker check target to the Makefile: