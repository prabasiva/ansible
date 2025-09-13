# 📦 Complete Installation Guide

This comprehensive guide will walk you through installing the Ansible Molecule development environment from scratch on your local machine.

## 📋 Table of Contents
1. [System Requirements](#system-requirements)
2. [macOS Installation](#macos-installation)
3. [Linux Installation](#linux-installation)
4. [Environment Setup](#environment-setup)
5. [Verification](#verification)
6. [Troubleshooting](#troubleshooting)
7. [Next Steps](#next-steps)

## 🔧 System Requirements

### Minimum Requirements
- **OS**: macOS 10.15+, Ubuntu 18.04+, CentOS/RHEL 8+
- **RAM**: 4GB (8GB+ recommended for multi-host testing)
- **CPU**: 2 cores (4+ recommended)
- **Disk**: 10GB free space
- **Network**: Internet connection for downloads

### Recommended Specifications
- **RAM**: 8-16GB
- **CPU**: 4-8 cores
- **Disk**: 20GB+ free space (SSD preferred)

---

## 🍎 macOS Installation

### Step 1: Install Homebrew (if not already installed)

```bash
# Check if Homebrew is installed
which brew

# If not installed, install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (for Apple Silicon Macs)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### Step 2: Install Docker Alternative (Colima)

```bash
# Install Colima and Docker CLI
brew install colima docker

# Start Colima with appropriate resources
colima start --cpu 4 --memory 8 --disk 60

# Verify installation
docker --version
colima version
colima status
```

### Step 3: Install Python and Development Tools

```bash
# Install Python 3 (if not already installed)
brew install python@3.11

# Install additional development tools
brew install git curl wget

# Verify Python installation
python3 --version
pip3 --version
```

### Step 4: Clone the Project

```bash
# Navigate to your preferred directory
cd ~/Documents

# Clone the repository (or use your existing directory)
# If you have the project locally:
cd /Users/prabasiva/Documents/2025/ansible/ansible.molecule

# Or clone from a repository:
# git clone <repository-url> ansible-molecule
# cd ansible-molecule
```

### Step 5: Set Up Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv ansible-molecule-env

# Activate virtual environment
source ansible-molecule-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install required packages
pip install -r requirements.txt
```

### Step 6: Install Ansible Collections

```bash
# Ensure virtual environment is activated
source ansible-molecule-env/bin/activate

# Install Ansible collections
ansible-galaxy install -r collections/requirements.yml
```

### Step 7: Verify Installation

```bash
# Check all tools are working
make verify-install

# Or manually verify:
ansible --version
molecule --version
docker run hello-world
colima status
```

---

## 🐧 Linux Installation

### For Ubuntu/Debian

#### Step 1: Update System

```bash
# Update package lists
sudo apt update
sudo apt upgrade -y

# Install basic tools
sudo apt install -y curl wget git build-essential software-properties-common
```

#### Step 2: Install Docker

```bash
# Remove old Docker versions
sudo apt-get remove docker docker-engine docker.io containerd runc

# Install dependencies
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add user to docker group
sudo usermod -aG docker $USER

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Logout and login again for group changes to take effect
echo "Please logout and login again, then continue with the installation"
```

#### Step 3: Install Python

```bash
# Install Python 3 and pip
sudo apt install -y python3 python3-pip python3-venv python3-dev

# Verify installation
python3 --version
pip3 --version
```

#### Step 4: Clone and Setup Project

```bash
# Navigate to your preferred directory
cd ~

# Clone the repository (adjust path as needed)
git clone <repository-url> ansible-molecule
cd ansible-molecule

# Or if you have the files locally, copy them to ~/ansible-molecule
```

#### Step 5: Set Up Python Virtual Environment

```bash
# Create virtual environment
python3 -m venv ansible-molecule-env

# Activate virtual environment
source ansible-molecule-env/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install required packages
pip install -r requirements.txt
```

#### Step 6: Install Ansible Collections

```bash
# Ensure virtual environment is activated
source ansible-molecule-env/bin/activate

# Install Ansible collections
ansible-galaxy install -r collections/requirements.yml
```

### For CentOS/RHEL

#### Step 1: Update System

```bash
# Update system
sudo yum update -y

# Install EPEL repository
sudo yum install -y epel-release

# Install basic tools
sudo yum install -y curl wget git gcc python3 python3-pip python3-devel
```

#### Step 2: Install Docker

```bash
# Install Docker repository
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
sudo yum install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER

# Logout and login again for group changes
echo "Please logout and login again, then continue with the installation"
```

#### Step 3: Continue with Python Setup

Follow the same steps as Ubuntu for Python virtual environment setup.

---

## 🔧 Environment Setup

### Automated Setup (Recommended)

```bash
# Use the provided Makefile for automated setup
make setup

# Activate virtual environment
source ansible-molecule-env/bin/activate
```

### Manual Setup

If the automated setup fails, follow these manual steps:

```bash
# 1. Create virtual environment
python3 -m venv ansible-molecule-env

# 2. Activate environment
source ansible-molecule-env/bin/activate

# 3. Upgrade pip
pip install --upgrade pip

# 4. Install Python packages
pip install \
    ansible>=6.0.0 \
    molecule>=4.0.0 \
    molecule[docker] \
    molecule-plugins[docker] \
    pytest-testinfra \
    docker \
    requests \
    ansible-lint \
    yamllint

# 5. Install Ansible collections
ansible-galaxy collection install community.general
ansible-galaxy collection install community.docker
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.crypto

# 6. Install from requirements file
ansible-galaxy install -r collections/requirements.yml
```

### Environment Variables (Optional)

Add these to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Ansible Molecule environment variables
export MOLECULE_NO_LOG=false
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks,timer

# For development/debugging
export MOLECULE_DEBUG=false
export ANSIBLE_VERBOSITY=1

# Add to shell profile
echo 'export ANSIBLE_HOST_KEY_CHECKING=false' >> ~/.bashrc
echo 'export ANSIBLE_STDOUT_CALLBACK=yaml' >> ~/.bashrc
source ~/.bashrc
```

---

## ✅ Verification

### Step 1: Check Dependencies

```bash
# Automated check
make check-deps
make check-docker

# Manual verification
ansible --version
molecule --version
docker --version

# For macOS with Colima
colima version
colima status

# For Linux
docker info
systemctl status docker
```

### Step 2: Test Docker

```bash
# Test basic Docker functionality
docker run hello-world

# Test Docker network
docker network ls

# Test container creation and removal
docker run --rm ubuntu:22.04 echo "Docker is working!"
```

### Step 3: Test Ansible

```bash
# Activate virtual environment if not already active
source ansible-molecule-env/bin/activate

# Test Ansible
ansible localhost -m ping

# Test Molecule
molecule --version
molecule list
```

### Step 4: Run Sample Tests

```bash
# Test default scenario (single container)
make test

# Test individual roles
make test-haproxy
make test-envoy
make test-common

# Test multi-host scenario (more comprehensive)
make test-multi
```

### Step 5: Complete Verification Script

```bash
#!/bin/bash
# Save as verify-installation.sh

echo "🔍 Verifying Ansible Molecule installation..."

# Check if virtual environment is activated
if [[ "$VIRTUAL_ENV" != *"ansible-molecule-env"* ]]; then
    echo "Activating virtual environment..."
    source ansible-molecule-env/bin/activate
fi

# Check Python packages
echo "1. Checking Python packages..."
python -c "import ansible; print(f'Ansible: {ansible.__version__}')"
python -c "import molecule; print(f'Molecule: {molecule.__version__}')"
python -c "import docker; print(f'Docker SDK: {docker.__version__}')"

# Check Docker
echo "2. Checking Docker..."
if command -v colima >/dev/null 2>&1; then
    echo "Colima status:"
    colima status
else
    echo "Docker status:"
    docker info | head -5
fi

# Test Docker functionality
echo "3. Testing Docker..."
docker run --rm hello-world

# Check Ansible collections
echo "4. Checking Ansible collections..."
ansible-galaxy collection list | grep -E "(community|ansible)"

# Test basic Ansible
echo "5. Testing Ansible..."
ansible localhost -m ping

# Test Molecule scenarios
echo "6. Testing Molecule scenarios..."
molecule list

echo "✅ Installation verification complete!"
```

```bash
# Make executable and run
chmod +x verify-installation.sh
./verify-installation.sh
```

---

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Virtual Environment Not Found
```bash
# Error: ansible-molecule-env not found
# Solution: Create the virtual environment
python3 -m venv ansible-molecule-env
source ansible-molecule-env/bin/activate
make setup
```

#### Issue 2: Docker Connection Errors (macOS)
```bash
# Error: Cannot connect to Docker daemon
# Solution: Start Colima
brew install colima docker
colima start --cpu 4 --memory 8
docker run hello-world
```

#### Issue 3: Docker Connection Errors (Linux)
```bash
# Error: Permission denied connecting to Docker
# Solution: Add user to docker group
sudo usermod -aG docker $USER
# Logout and login again
newgrp docker
docker run hello-world
```

#### Issue 4: Python Module Import Errors
```bash
# Error: ModuleNotFoundError
# Solution: Reinstall in virtual environment
source ansible-molecule-env/bin/activate
pip install --upgrade --force-reinstall ansible molecule[docker]
```

#### Issue 5: Ansible Collection Not Found
```bash
# Error: Collection not found
# Solution: Reinstall collections
source ansible-molecule-env/bin/activate
ansible-galaxy install -r collections/requirements.yml --force
```

#### Issue 6: Port Conflicts
```bash
# Error: Port already in use
# Solution: Clean up containers
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
make clean
```

#### Issue 7: Memory/Resource Issues
```bash
# For macOS/Colima: Increase resources
colima stop
colima start --cpu 4 --memory 8 --disk 60

# For Linux: Check available resources
free -h
df -h
```

### Getting Help

If you encounter issues not covered here:

1. **Check logs**: `molecule logs`
2. **Run with debug**: `molecule --debug test`
3. **Check the main troubleshooting guide**: [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
4. **Clean and retry**: `make clean && make setup`

---

## 🎯 Next Steps

### Quick Start Testing

```bash
# 1. Activate environment
source ansible-molecule-env/bin/activate

# 2. Run quick test
make test

# 3. Run comprehensive test
make test-multi

# 4. Start development environment
make dev-start
```

### Development Workflow

```bash
# Daily workflow
source ansible-molecule-env/bin/activate  # Always activate first
make dev-start                           # Deploy infrastructure
make login                               # Debug if needed
make dev-test                           # Test changes
make dev-stop                           # Clean up
```

### Available Commands

```bash
# See all available commands
make help

# Key commands:
make setup           # Initial setup
make test-all        # Run all tests
make test-multi      # Multi-host testing
make test-failure    # Failure scenarios
make clean          # Clean up Docker
make update         # Update dependencies
```

### Learning Resources

1. **Project Documentation**:
   - [README.md](README.md) - Main documentation
   - [QUICKSTART.md](QUICKSTART.md) - 5-minute quick start
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Detailed troubleshooting

2. **External Resources**:
   - [Ansible Documentation](https://docs.ansible.com/)
   - [Molecule Documentation](https://molecule.readthedocs.io/)
   - [Colima Documentation](https://github.com/abiosoft/colima)
   - [Docker Documentation](https://docs.docker.com/)

### Customization

1. **Modify roles**: Check `roles/` directory
2. **Adjust scenarios**: Edit files in `molecule/` directories
3. **Configure environments**: Modify `group_vars/` files
4. **Add new tests**: Create new playbooks in `playbooks/`

---

## 🎉 Installation Complete!

Your Ansible Molecule development environment is now fully installed and ready to use!

**What you can do now:**
- ✅ Test infrastructure automation
- ✅ Develop Ansible roles with confidence  
- ✅ Run comprehensive integration tests
- ✅ Simulate failure scenarios
- ✅ Monitor logs and metrics
- ✅ Learn infrastructure as code best practices

**Remember to always activate your virtual environment:**
```bash
source ansible-molecule-env/bin/activate
```

**Happy testing! 🚀**