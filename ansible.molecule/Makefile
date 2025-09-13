# Ansible Molecule Development Environment Makefile
# Provides convenient commands for common tasks

.PHONY: help install test test-all clean lint setup check-deps

# Default target
help: ## Show this help message
	@echo "Ansible Molecule Development Environment"
	@echo "======================================"
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup and Installation
setup: ## Set up the development environment
	@echo "Setting up Ansible Molecule environment..."
	python3 -m venv ansible-molecule-env
	. ansible-molecule-env/bin/activate && \
		pip install --upgrade pip && \
		pip install ansible molecule[docker] molecule-plugins[docker] pytest-testinfra docker requests
	. ansible-molecule-env/bin/activate && \
		ansible-galaxy install -r collections/requirements.yml
	@echo "Setup complete! Run 'source ansible-molecule-env/bin/activate' to activate environment"

check-deps: ## Check if all dependencies are installed
	@echo "Checking dependencies..."
	@command -v docker >/dev/null 2>&1 || { echo "Docker not installed"; exit 1; }
	@command -v python3 >/dev/null 2>&1 || { echo "Python3 not installed"; exit 1; }
	@if [ ! -d "ansible-molecule-env" ]; then echo "Virtual environment not found. Run 'make setup'"; exit 1; fi
	@. ansible-molecule-env/bin/activate && command -v molecule >/dev/null 2>&1 || { echo "Molecule not installed"; exit 1; }
	@echo "All dependencies are installed"

check-docker: ## Check if Docker (via Colima) is running and accessible
	@echo "Checking Docker/Colima status..."
	@if ! command -v colima >/dev/null 2>&1; then \
		echo "Colima is not installed"; \
		echo "   Installing Colima and Docker..."; \
		brew install colima docker; \
	fi
	@if ! colima status | grep -q "Running" 2>/dev/null; then \
		echo "Colima is not running"; \
		echo "   Starting Colima with 4 CPU and 8GB memory..."; \
		colima start --cpu 4 --memory 8; \
	else \
		echo "Colima is running"; \
	fi
	@if ! docker info >/dev/null 2>&1; then \
		echo "Cannot connect to Docker daemon"; \
		echo "   Please ensure Colima is fully started and try again"; \
		exit 1; \
	else \
		echo "Docker daemon is accessible"; \
	fi
	@if docker run --rm hello-world >/dev/null 2>&1; then \
		echo "Docker is working correctly"; \
	else \
		echo "Docker test failed"; \
		exit 1; \
	fi
	@echo "Docker with Colima is ready for Molecule testing!"

# Testing targets
test: check-deps check-docker ## Run default Molecule test
	@echo "Running default Molecule test..."
	. ansible-molecule-env/bin/activate && molecule test

test-multi: check-deps check-docker ## Run multi-host scenario test
	@echo "Running multi-host scenario test..."
	. ansible-molecule-env/bin/activate && molecule test -s multi-host

test-failure: check-deps check-docker ## Run failure scenarios test
	@echo "Running failure scenarios test..."
	. ansible-molecule-env/bin/activate && molecule test -s failure-scenarios

test-all: test test-multi test-failure ## Run all test scenarios
	@echo "All tests completed!"

# Individual role testing
test-haproxy: check-deps ## Test HAProxy role
	@echo "Testing HAProxy role..."
	cd roles/haproxy && ../../ansible-molecule-env/bin/molecule test

test-envoy: check-deps ## Test Envoy Proxy role
	@echo "Testing Envoy Proxy role..."
	cd roles/envoyproxy && ../../ansible-molecule-env/bin/molecule test

test-common: check-deps ## Test Common infrastructure role
	@echo "Testing Common infrastructure role..."
	cd roles/common && ../../ansible-molecule-env/bin/molecule test

# Happy path and integration testing
test-happy: check-deps ## Run happy path tests
	@echo "Running happy path tests..."
	. ansible-molecule-env/bin/activate && \
		ansible-playbook playbooks/test-happy-path.yml -i inventory/hosts.yml

test-integration: check-deps ## Run full integration tests
	@echo "Running integration tests..."
	. ansible-molecule-env/bin/activate && \
		molecule create -s multi-host && \
		molecule converge -s multi-host && \
		ansible-playbook playbooks/test-happy-path.yml -i molecule/multi-host/inventory/hosts.yml && \
		molecule verify -s multi-host && \
		molecule destroy -s multi-host
	@echo "Integration tests completed!"

# Development and debugging
debug: check-deps check-docker ## Run multi-host scenario with debug output
	@echo "Running multi-host scenario in debug mode..."
	. ansible-molecule-env/bin/activate && molecule --debug test -s multi-host

converge: check-deps check-docker ## Run converge step only (deploy without testing)
	@echo "Running converge step..."
	. ansible-molecule-env/bin/activate && molecule converge -s multi-host

verify: check-deps ## Run verify step only (test existing deployment)
	@echo "Running verify step..."
	. ansible-molecule-env/bin/activate && molecule verify -s multi-host

login: check-deps ## Login to the first container for debugging
	@echo "Logging into container for debugging..."
	. ansible-molecule-env/bin/activate && molecule login -s multi-host

destroy: check-deps ## Destroy test infrastructure
	@echo "Destroying test infrastructure..."
	. ansible-molecule-env/bin/activate && molecule destroy -s multi-host

# Linting and validation
lint: check-deps ## Run Ansible linting
	@echo "Running Ansible lint..."
	. ansible-molecule-env/bin/activate && ansible-lint roles/ playbooks/

syntax: check-deps ## Check Ansible syntax
	@echo "Checking Ansible syntax..."
	. ansible-molecule-env/bin/activate && \
		ansible-playbook --syntax-check playbooks/site.yml -i inventory/hosts.yml && \
		ansible-playbook --syntax-check playbooks/development.yml -i inventory/hosts.yml && \
		ansible-playbook --syntax-check playbooks/production.yml -i inventory/hosts.yml

validate: lint syntax ## Run all validation checks
	@echo "All validation checks passed!"

# Environment management
clean: ## Clean up Docker containers and images
	@echo "Cleaning up Docker resources..."
	-docker stop $$(docker ps -aq)
	-docker rm $$(docker ps -aq)
	-docker rmi $$(docker images -q --filter "dangling=true")
	-docker system prune -f

clean-all: clean ## Clean up everything including virtual environment
	@echo "Cleaning up virtual environment..."
	rm -rf ansible-molecule-env
	@echo "Cleanup complete!"

# Utility targets
logs: check-deps ## Show logs from running containers
	@echo "Showing container logs..."
	. ansible-molecule-env/bin/activate && molecule logs -s multi-host

status: check-deps ## Show status of Molecule scenarios
	@echo "Molecule scenarios status:"
	. ansible-molecule-env/bin/activate && molecule list

ps: ## Show running Docker containers
	@echo "Running containers:"
	docker ps

images: ## Show Docker images
	@echo "Docker images:"
	docker images

# Quick development workflow
dev-start: converge ## Quick start for development (converge only)
	@echo "Development environment is ready!"
	@echo "Access points:"
	@echo "  - HAProxy stats: http://localhost:8080/stats (admin/admin123)"
	@echo "  - Envoy admin: http://localhost:9901/"
	@echo "Run 'make login' to debug containers"

dev-test: verify ## Quick test of current deployment
	@echo "Testing current deployment..."

dev-stop: destroy ## Stop development environment
	@echo "Development environment stopped"

# CI/CD helpers
ci-test: check-deps ## Run CI-friendly tests (non-interactive)
	@echo "Running CI tests..."
	. ansible-molecule-env/bin/activate && \
		molecule test --all

ci-prepare: ## Prepare environment for CI
	@echo "Preparing CI environment..."
	docker info
	python3 --version
	pip install --upgrade pip
	pip install ansible molecule[docker] molecule-plugins[docker] pytest-testinfra

# Documentation
docs: ## Open documentation
	@echo "Opening documentation..."
	@if command -v open >/dev/null 2>&1; then \
		open README.md; \
	elif command -v xdg-open >/dev/null 2>&1; then \
		xdg-open README.md; \
	else \
		echo "Please open README.md in your preferred editor"; \
	fi

# Installation verification
verify-install: check-deps ## Verify installation is working
	@echo "Verifying installation..."
	. ansible-molecule-env/bin/activate && \
		molecule --version && \
		ansible --version && \
		docker run --rm hello-world
	@echo "Installation verification complete!"

# Update dependencies
update: check-deps ## Update all dependencies
	@echo "Updating dependencies..."
	. ansible-molecule-env/bin/activate && \
		pip install --upgrade ansible molecule[docker] molecule-plugins[docker] pytest-testinfra && \
		ansible-galaxy install -r collections/requirements.yml --force
	@echo "Dependencies updated!"