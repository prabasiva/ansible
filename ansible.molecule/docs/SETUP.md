# Ansible Molecule Setup Instructions

This document provides step-by-step instructions to set up and run the Ansible Molecule development and test environment.

## 🔧 System Requirements

- **Operating System**: Ubuntu 20.04+, macOS 10.15+, or RHEL/CentOS 8+
- **RAM**: Minimum 8GB (16GB recommended for full multi-host testing)
- **Disk Space**: 20GB free space
- **CPU**: 2+ cores (4+ recommended)
- **Network**: Internet connection for downloading packages and Docker images

## 📋 Step-by-Step Setup

### Step 1: Install Docker

#### Ubuntu/Debian
```bash
# Remove old versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again for group changes to take effect
```

#### macOS (using Colima - Lightweight Alternative)
```bash
# Install Colima and Docker CLI via Homebrew
brew install colima docker

# Start Colima with appropriate resources
colima start --cpu 4 --memory 8

# Verify installation
docker --version
colima version
```

### Step 2: Install Python and Virtual Environment

#### Ubuntu/Debian
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv python3-dev build-essential
```

#### macOS
```bash
# Using Homebrew
brew install python3

# Or use the system Python (macOS 10.15+)
```

### Step 3: Create Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv ansible-molecule-env

# Activate virtual environment
source ansible-molecule-env/bin/activate

# Verify activation (should show path to venv)
which python
```

### Step 4: Install Ansible and Molecule

```bash
# Ensure virtual environment is activated
source ansible-molecule-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Ansible and Molecule with required plugins
pip install \
    ansible>=6.0.0 \
    molecule[docker]>=4.0.0 \
    molecule-plugins[docker] \
    pytest-testinfra \
    docker \
    requests

# Verify installation
ansible --version
molecule --version
```

### Step 5: Clone and Setup Project

```bash
# Navigate to your projects directory
cd ~/projects

# If cloning from git (replace with actual repository)
git clone <repository-url> ansible.molecule
cd ansible.molecule

# Or use the existing directory
cd /Users/prabasiva/Documents/2025/ansible/ansible.molecule

# Install Ansible collections
ansible-galaxy install -r collections/requirements.yml
```

### Step 6: Verify Docker/Colima Setup

#### For macOS with Colima:
```bash
# Check Colima status
colima status

# Test Docker installation
docker run hello-world

# List Docker networks (should include default networks)
docker network ls

# Check if docker daemon is running
docker info
```

#### For Linux with Docker:
```bash
# Test Docker installation
docker run hello-world

# List Docker networks (should include default networks)
docker network ls

# Check if docker daemon is running
docker info
```

### Step 7: Test Basic Molecule Functionality

```bash
# Test default scenario
molecule test

# If successful, test individual roles
cd roles/haproxy
molecule test
cd ../..

# Test multi-host scenario
molecule test -s multi-host
```

## 🚀 Quick Verification

Run these commands to verify everything is working:

```bash
# 1. Activate virtual environment
source ansible-molecule-env/bin/activate

# 2. Check versions
ansible --version
molecule --version
docker --version

# 3. Test Docker connectivity
docker run --rm hello-world

# 4. Test Molecule scenarios
molecule list

# 5. Run a quick test
molecule test -s default

# 6. Check if all services work in multi-host
molecule create -s multi-host
molecule converge -s multi-host
molecule verify -s multi-host
molecule destroy -s multi-host
```

## 🔍 Common Setup Issues and Solutions

### Issue 1: Docker Permission Denied
```bash
# Error: Got permission denied while trying to connect to Docker daemon
# Solution:
sudo usermod -aG docker $USER
newgrp docker
# Or logout and login again
```

### Issue 2: Python Module Not Found
```bash
# Error: ModuleNotFoundError: No module named 'molecule'
# Solution:
source ansible-molecule-env/bin/activate
pip install molecule[docker]
```

### Issue 3: Docker Network Issues
```bash
# Error: Could not connect to Docker daemon
# Solution:
sudo systemctl start docker
sudo systemctl enable docker
```

### Issue 4: Ansible Collection Issues
```bash
# Error: couldn't resolve module/action
# Solution:
ansible-galaxy collection install community.docker
ansible-galaxy collection install community.general
ansible-galaxy install -r collections/requirements.yml --force
```

### Issue 5: Port Already in Use
```bash
# Error: Port 8080 is already allocated
# Solution:
docker ps -a  # Find conflicting containers
docker stop <container_id>
docker rm <container_id>
# Or change ports in molecule.yml
```

## 📊 Performance Optimization

### For Better Performance:

1. **Increase Docker Resources** (Docker Desktop):
   - Memory: 4-8GB
   - CPU: 2-4 cores
   - Disk: 64GB

2. **Use SSD Storage** for Docker data directory

3. **Enable Docker BuildKit**:
   ```bash
   export DOCKER_BUILDKIT=1
   ```

4. **Parallel Testing**:
   ```bash
   # Run tests in parallel (if system resources allow)
   molecule test --parallel
   ```

## 🔧 Environment Variables

Set these environment variables for better experience:

```bash
# Add to ~/.bashrc or ~/.zshrc
export MOLECULE_NO_LOG=false
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks,timer

# For development
export MOLECULE_DEBUG=true
export ANSIBLE_VERBOSITY=2
```

## 📱 IDE/Editor Setup

### VS Code Extensions
```bash
# Install recommended extensions
code --install-extension ms-python.python
code --install-extension redhat.ansible
code --install-extension ms-vscode.docker
```

### VS Code Settings (`.vscode/settings.json`)
```json
{
    "python.defaultInterpreterPath": "./ansible-molecule-env/bin/python",
    "ansible.python.interpreterPath": "./ansible-molecule-env/bin/python",
    "files.associations": {
        "*.yml": "ansible"
    }
}
```

## 🧪 Testing Your Setup

### Complete Test Suite
```bash
#!/bin/bash
# save as test-setup.sh

set -e

echo "Testing Ansible Molecule Setup..."

# Check if virtual environment is activated
if [[ "$VIRTUAL_ENV" != *"ansible-molecule-env"* ]]; then
    echo "Activating virtual environment..."
    source ansible-molecule-env/bin/activate
fi

# Test 1: Check required tools
echo "1. Checking tool versions..."
ansible --version
molecule --version
docker --version

# Test 2: Test Docker
echo "2. Testing Docker connectivity..."
docker run --rm hello-world

# Test 3: Test Molecule scenarios
echo "3. Testing Molecule scenarios..."
molecule list

# Test 4: Test default scenario
echo "4. Testing default scenario..."
molecule test -s default

# Test 5: Test multi-host scenario
echo "5. Testing multi-host scenario..."
molecule create -s multi-host
molecule converge -s multi-host
molecule verify -s multi-host
molecule destroy -s multi-host

echo "✅ All tests passed! Setup is complete."
```

```bash
# Make executable and run
chmod +x test-setup.sh
./test-setup.sh
```

## 🎯 Next Steps After Setup

1. **Read the main README.md** for usage instructions
2. **Run your first test**: `molecule test -s multi-host`
3. **Explore the roles**: Check `roles/` directory
4. **Customize configurations**: Modify `group_vars/` files
5. **Run failure scenarios**: `molecule test -s failure-scenarios`
6. **Check logs**: Monitor `logs/` directory for test results

## 💡 Tips for Success

1. **Always activate virtual environment** before working
2. **Check Docker status** if tests fail
3. **Use descriptive commit messages** when making changes
4. **Test changes locally** before pushing to repository
5. **Monitor system resources** during multi-host testing
6. **Keep virtual environment updated**: `pip install --upgrade -r requirements.txt`

## 🆘 Getting Help

If you encounter issues:

1. **Check the troubleshooting section** in main README.md
2. **Review container logs**: `molecule logs`
3. **Debug with verbose output**: `molecule test --debug`
4. **Check GitHub issues** for similar problems
5. **Create detailed issue reports** with:
   - Error messages
   - System information (`uname -a`, `docker info`)
   - Steps to reproduce
   - Log files

## 🏁 Setup Complete!

Your Ansible Molecule development environment is now ready. You can start testing and developing infrastructure automation with confidence!