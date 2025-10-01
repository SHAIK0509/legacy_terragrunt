# ========================================================
# Makefile for Terragrunt Infrastructure
# Repo: legacy_terragrunt/terragrunt/ec2-terragrunt
# ========================================================

TERRAFORM_VERSION ?= 0.13.6
TERRAGRUNT_VERSION ?= 0.27.1
TERRAFORM_BIN := $(CURDIR)/terraform
TERRAGRUNT_BIN := $(CURDIR)/terragrunt

# Modules to manage (comma-separated in Jenkins, space here)
MODULES := ec2 prod-ec2 stage-ec2
ENV ?= dev  # default environment
TG_BASE_DIR := live/$(ENV)

# Detect OS for Terraform/Terragrunt download
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    TERRAFORM_OS := darwin_amd64
    TERRAGRUNT_OS := darwin_amd64
else
    TERRAFORM_OS := linux_amd64
    TERRAGRUNT_OS := linux_amd64
endif

# ========================================================
# Install Terraform & Terragrunt
# ========================================================
.PHONY: install
install:
	@echo "Installing Terraform v$(TERRAFORM_VERSION)..."
	curl -L -o terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(TERRAFORM_OS).zip
	unzip -o terraform.zip -d .
	chmod +x terraform
	./terraform --version

	@echo "Installing Terragrunt v$(TERRAGRUNT_VERSION)..."
	curl -L -o terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v$(TERRAGRUNT_VERSION)/terragrunt_$(TERRAGRUNT_OS)
	chmod +x terragrunt
	./terragrunt --version

# ========================================================
# Plan for all modules
# ========================================================
.PHONY: plan
plan: install
	@for module in $(MODULES); do \
		echo "==============================================="; \
		echo "Running terragrunt plan in $(TG_BASE_DIR)/$$module"; \
		( cd $(TG_BASE_DIR)/$$module && \
		  rm -rf .terragrunt-cache || true && \
		  PATH=$(CURDIR):$$PATH terragrunt init -reconfigure && \
		  PATH=$(CURDIR):$$PATH terragrunt plan ); \
		echo "==============================================="; \
	done

# ========================================================
# Apply for all modules
# ========================================================
.PHONY: apply
apply: install
	@for module in $(MODULES); do \
		echo "==============================================="; \
		echo "Running terragrunt apply in $(TG_BASE_DIR)/$$module"; \
		( cd $(TG_BASE_DIR)/$$module && \
		  rm -rf .terragrunt-cache || true && \
		  PATH=$(CURDIR):$$PATH terragrunt apply -auto-approve ); \
		echo "==============================================="; \
	done

# ========================================================
# Output
# ========================================================
.PHONY: output
output: install
	@for module in $(MODULES); do \
		echo "==============================================="; \
		echo "Fetching outputs from $(TG_BASE_DIR)/$$module"; \
		( cd $(TG_BASE_DIR)/$$module && \
		  PATH=$(CURDIR):$$PATH terragrunt output ); \
		echo "==============================================="; \
	done

# ========================================================
# Clean
# ========================================================
.PHONY: clean
clean:
	rm -f terraform terraform.zip terragrunt
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} +
