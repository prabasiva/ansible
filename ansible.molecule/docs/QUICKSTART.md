# 🚀 Quick Start Guide

Get up and running with the Ansible Molecule development environment in 5 minutes!

## ⚡ One-Command Setup

```bash
# For macOS, first install Colima (lightweight Docker alternative)
brew install colima docker && colima start --cpu 4 --memory 8

# Then run this single command to set up everything
make setup && source ansible-molecule-env/bin/activate
```

## ✅ Verify Installation

```bash
# Test that everything works
make verify-install
```

## 🧪 Run Your First Test

```bash
# Test individual services
make test-haproxy    # Test HAProxy role
make test-envoy      # Test Envoy Proxy role

# Test full multi-host scenario
make test-multi      # Complete integration test
```

## 🎯 Quick Development Workflow

```bash
# Start development environment
make dev-start       # Deploy all services

# Test current deployment  
make dev-test        # Verify everything works

# Debug if needed
make login          # SSH into containers

# Stop when done
make dev-stop       # Clean up
```

## 📊 Access Your Services

Once deployed, access these endpoints:

- **HAProxy Stats**: http://localhost:8404/stats (admin/admin123)
- **Envoy Admin**: http://localhost:9901/
- **Kibana Logs**: http://localhost:5601/
- **Elasticsearch**: http://localhost:9200/

## 🆘 Quick Troubleshooting

**Docker/Colima issues?**
```bash
# For macOS with Colima
colima stop && colima start --cpu 4 --memory 8

# For Linux with Docker
sudo usermod -aG docker $USER
# Logout and login again
```

**Port conflicts?**
```bash
make clean          # Clean up containers
```

**Module not found?**
```bash
source ansible-molecule-env/bin/activate
make update
```

## 📚 What's Next?

- Read the full [README.md](README.md) for detailed documentation
- Check [SETUP.md](SETUP.md) for detailed setup instructions
- Explore the `roles/` directory to understand the infrastructure
- Run `make help` to see all available commands

## 🎉 You're Ready!

Your Ansible Molecule environment is set up and ready for infrastructure testing and development!