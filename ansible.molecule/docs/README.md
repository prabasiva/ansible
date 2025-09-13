# Ansible Molecule Development & Test Environment

A comprehensive Ansible testing environment using Molecule with Docker, featuring HAProxy, Envoy Proxy, common infrastructure setup, and external logging integration.

## 🚀 Quick Start

### Prerequisites

1. **Install Required Tools**
   ```bash
   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   sudo usermod -aG docker $USER
   
   # Install Python and pip
   sudo apt update
   sudo apt install python3 python3-pip python3-venv
   
   # Create virtual environment
   python3 -m venv ansible-venv
   source ansible-venv/bin/activate
   
   # Install Ansible and Molecule
   pip install ansible molecule[docker] molecule-plugins[docker] pytest-testinfra
   ```

2. **Install Ansible Collections**
   ```bash
   ansible-galaxy install -r collections/requirements.yml
   ```

### Running Tests

#### Basic Single-Role Testing
```bash
# Test HAProxy role
cd roles/haproxy
molecule test

# Test Envoy Proxy role  
cd roles/envoyproxy
molecule test

# Test Common Infrastructure role
cd roles/common
molecule test
```

#### Multi-Host Integration Testing
```bash
# Run multi-host scenario
molecule test -s multi-host

# Run with specific inventory
molecule converge -s multi-host
molecule verify -s multi-host
```

#### Failure Scenario Testing
```bash
# Run failure scenarios
molecule test -s failure-scenarios

# Manual failure testing
molecule converge -s failure-scenarios
molecule side_effect -s failure-scenarios
molecule verify -s failure-scenarios
```

## 📁 Project Structure

```
ansible.molecule/
├── ansible.cfg                 # Ansible configuration
├── collections/               
│   └── requirements.yml       # Required Ansible collections
├── inventory/
│   └── hosts.yml              # Multi-host inventory
├── group_vars/
│   ├── all.yml               # Global variables
│   ├── haproxy_servers.yml   # HAProxy-specific vars
│   └── envoy_servers.yml     # Envoy-specific vars
├── roles/
│   ├── haproxy/              # HAProxy role
│   ├── envoyproxy/           # Envoy Proxy role
│   ├── common/               # Common infrastructure
│   ├── templates/            # System templates
│   └── logging/              # ELK stack logging
├── playbooks/
│   ├── site.yml              # Main deployment playbook
│   ├── development.yml       # Development environment
│   ├── production.yml        # Production environment
│   ├── test-happy-path.yml   # Happy path testing
│   └── test-failure.yml      # Failure scenario testing
├── molecule/
│   ├── default/              # Default test scenario
│   ├── multi-host/           # Multi-host testing
│   └── failure-scenarios/    # Failure testing
└── logs/                     # Test results and logs
```

## 🔧 Available Roles

### 1. HAProxy Role (`roles/haproxy`)
- **Purpose**: Load balancer and SSL termination
- **Features**: 
  - Automated installation and configuration
  - SSL certificate management
  - Stats interface with authentication
  - Health checks and monitoring
  - Custom backend configuration

**Usage:**
```yaml
- hosts: haproxy_servers
  roles:
    - role: haproxy
      vars:
        haproxy_backends:
          - name: web_servers
            balance: roundrobin
            servers:
              - name: web1
                address: "192.168.1.10:80"
                check: true
```

### 2. Envoy Proxy Role (`roles/envoyproxy`)
- **Purpose**: Modern edge and service proxy
- **Features**:
  - Dynamic configuration
  - Advanced load balancing
  - Circuit breaking and retry policies
  - Detailed metrics and observability
  - Health check endpoints

**Usage:**
```yaml
- hosts: envoy_servers
  roles:
    - role: envoyproxy
      vars:
        envoy_clusters:
          - name: service_backend
            type: LOGICAL_DNS
            lb_policy: ROUND_ROBIN
```

### 3. Common Infrastructure Role (`roles/common`)
- **Purpose**: Base system setup and hardening
- **Features**:
  - SSL certificate generation
  - OS patching and updates
  - Filebeat log shipping
  - Security hardening (UFW, Fail2Ban)
  - System monitoring

### 4. Templates Role (`roles/templates`)
- **Purpose**: System configuration templates
- **Features**:
  - Netplan network configuration
  - Custom bash prompts and aliases
  - Logrotate configuration
  - System optimization

### 5. Logging Role (`roles/logging`)
- **Purpose**: Centralized logging with ELK stack
- **Features**:
  - Elasticsearch cluster setup
  - Kibana dashboard configuration
  - Logstash log processing
  - Automated log forwarding

## 🎯 Test Scenarios

### Happy Path Testing
Validates normal operations and functionality:
```bash
# Run happy path tests
ansible-playbook playbooks/test-happy-path.yml -i inventory/hosts.yml
```

**Tests Include:**
- Service health checks
- Proxy functionality
- Load balancing
- SSL certificates
- Configuration validation
- End-to-end connectivity

### Failure Scenario Testing
Tests system resilience and recovery:
```bash
# Run failure scenarios
molecule test -s failure-scenarios
```

**Scenarios Include:**
- Service stop/start recovery
- Configuration error handling
- Network partition simulation
- Resource exhaustion testing
- High load resistance
- Disk space handling

## 📊 Environment Types

### Development Environment
```bash
ansible-playbook playbooks/development.yml -i inventory/hosts.yml
```
- Minimal security settings
- Debug logging enabled
- Auto-reboot disabled
- Development-friendly configurations

### Production Environment
```bash
ansible-playbook playbooks/production.yml -i inventory/hosts.yml
```
- Full security hardening
- Optimized performance settings
- Automated patching enabled
- Production monitoring

## 📈 Monitoring & Logging

### Access Points
- **HAProxy Stats**: `http://haproxy-server:8404/stats` (admin/admin123)
- **Envoy Admin**: `http://envoy-server:9901/`
- **Kibana Dashboard**: `http://log-server:5601`
- **Elasticsearch API**: `http://log-server:9200`

### Log Types Collected
- HAProxy access and error logs
- Envoy access logs and admin logs
- System logs (syslog, auth.log)
- Application-specific logs
- Monitoring metrics
- Test execution results

## 🔍 Troubleshooting

### Common Issues

1. **Docker Permission Errors**
   ```bash
   sudo usermod -aG docker $USER
   # Logout and login again
   ```

2. **Molecule Command Not Found**
   ```bash
   source ansible-venv/bin/activate
   pip install molecule[docker]
   ```

3. **Port Conflicts**
   ```bash
   # Check for port usage
   netstat -tulpn | grep :8080
   
   # Kill conflicting processes
   sudo kill -9 <PID>
   ```

4. **Service Start Failures**
   ```bash
   # Check service status
   molecule login
   systemctl status haproxy
   journalctl -u haproxy -f
   ```

### Debug Commands

```bash
# Enter container for debugging
molecule login -s multi-host -h haproxy-01

# Check container logs
molecule logs -s multi-host

# Validate configurations
molecule syntax -s multi-host

# Manual testing steps
molecule create -s multi-host
molecule converge -s multi-host
molecule verify -s multi-host
```

## 🚀 Advanced Usage

### Custom Scenarios

1. **Create New Scenario**
   ```bash
   mkdir molecule/custom-scenario
   cp molecule/default/molecule.yml molecule/custom-scenario/
   # Edit configuration as needed
   ```

2. **Run Custom Tests**
   ```bash
   molecule test -s custom-scenario
   ```

### CI/CD Integration

```yaml
# .github/workflows/molecule.yml
name: Molecule Tests
on: [push, pull_request]
jobs:
  molecule:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install molecule[docker] ansible
          ansible-galaxy install -r collections/requirements.yml
      - name: Run Molecule tests
        run: molecule test -s multi-host
```

## 📝 Configuration Examples

### Custom HAProxy Backend
```yaml
haproxy_backends:
  - name: api_servers
    balance: leastconn
    option:
      - httpchk GET /api/health
      - tcp-check
    http-check:
      expect: status 200
    servers:
      - name: api1
        address: "10.0.1.10:8080"
        check: true
        weight: 100
        maxconn: 500
      - name: api2
        address: "10.0.1.11:8080"
        check: true
        weight: 100
        maxconn: 500
```

### Custom Envoy Configuration
```yaml
envoy_clusters:
  - name: microservice_cluster
    connect_timeout: 5s
    type: STRICT_DNS
    lb_policy: LEAST_REQUEST
    health_checks:
      - timeout: 1s
        interval: 10s
        path: "/health"
    load_assignment:
      cluster_name: microservice_cluster
      endpoints:
        - lb_endpoints:
            - endpoint:
                address:
                  socket_address:
                    address: microservice.local
                    port_value: 8080
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/awesome-feature`)
3. Commit changes (`git commit -am 'Add awesome feature'`)
4. Push to branch (`git push origin feature/awesome-feature`)
5. Create Pull Request

### Testing Your Changes
```bash
# Test all scenarios before submitting PR
molecule test
molecule test -s multi-host
molecule test -s failure-scenarios

# Run happy path tests
ansible-playbook playbooks/test-happy-path.yml -i inventory/hosts.yml
```

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check existing GitHub issues
2. Review troubleshooting section
3. Create new issue with detailed description and logs

## 📚 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [HAProxy Documentation](http://www.haproxy.org/#docs)
- [Envoy Proxy Documentation](https://www.envoyproxy.io/docs/)
- [Docker Documentation](https://docs.docker.com/)