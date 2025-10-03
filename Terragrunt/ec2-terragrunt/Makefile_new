# ========================================================
# Makefile for Terragrunt Infrastructure
# Repo: terragrunt/ec2-terragrunt
# ========================================================

TERRAFORM_VERSION ?= 0.13.6
TERRAGRUNT_VERSION ?= 0.27.1
BIN_DIR := $(CURDIR)/bin
TERRAFORM_BIN := $(BIN_DIR)/terraform
TERRAGRUNT_BIN := $(BIN_DIR)/terragrunt

# Modules to manage
MODULES := dev stage prod
ENV ?= dev  # default environment
TG_BASE_DIR := $(CURDIR)/live  # points to live folder

# Detect OS
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
	@mkdir -p $(BIN_DIR)
	@echo "Installing Terraform v$(TERRAFORM_VERSION)..."
	curl -L -o $(BIN_DIR)/terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(TERRAFORM_OS).zip
	unzip -o $(BIN_DIR)/terraform.zip -d $(BIN_DIR)
	chmod +x $(TERRAFORM_BIN)
	$(TERRAFORM_BIN) --version

	@echo "Installing Terragrunt v$(TERRAGRUNT_VERSION)..."
	curl -L -o $(TERRAGRUNT_BIN) https://github.com/gruntwork-io/terragrunt/releases/download/v$(TERRAGRUNT_VERSION)/terragrunt_$(TERRAGRUNT_OS)
	chmod +x $(TERRAGRUNT_BIN)
	$(TERRAGRUNT_BIN) --version

# ========================================================
# Plan
# ========================================================
.PHONY: plan
plan: install
	@set -x; for module in $(MODULES); do \
		if [ -n "$(ENV)" ] && [ "$$module" != "$(ENV)" ]; then continue; fi; \
		MODULE_PATH="$(TG_BASE_DIR)/$$module"; \
		if [ -d "$$MODULE_PATH" ]; then \
			echo "==============================================="; \
			echo "Running terragrunt plan in $$MODULE_PATH"; \
			( cd "$$MODULE_PATH" && \
			  rm -rf .terragrunt-cache || true && \
			  PATH=$(BIN_DIR):$$PATH terragrunt init -reconfigure && \
			  PATH=$(BIN_DIR):$$PATH terragrunt plan ); \
			echo "==============================================="; \
		else \
			echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
		fi \
	done

# ========================================================
# Apply
# ========================================================
.PHONY: apply
apply: install
	@set -x; for module in $(MODULES); do \
		if [ -n "$(ENV)" ] && [ "$$module" != "$(ENV)" ]; then continue; fi; \
		MODULE_PATH="$(TG_BASE_DIR)/$$module"; \
		if [ -d "$$MODULE_PATH" ]; then \
			echo "==============================================="; \
			echo "Running terragrunt apply in $$MODULE_PATH"; \
			( cd "$$MODULE_PATH" && \
			  rm -rf .terragrunt-cache || true && \
			  PATH=$(BIN_DIR):$$PATH terragrunt apply -auto-approve ); \
			echo "==============================================="; \
		else \
			echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
		fi \
	done

# ========================================================
# Destroy
# ========================================================
.PHONY: destroy
destroy: install
	@set -x; for module in $(MODULES); do \
		if [ -n "$(ENV)" ] && [ "$$module" != "$(ENV)" ]; then continue; fi; \
		MODULE_PATH="$(TG_BASE_DIR)/$$module"; \
		if [ -d "$$MODULE_PATH" ]; then \
			echo "==============================================="; \
			echo "Running terragrunt destroy in $$MODULE_PATH"; \
			( cd "$$MODULE_PATH" && \
			  rm -rf .terragrunt-cache || true && \
			  PATH=$(BIN_DIR):$$PATH terragrunt destroy -auto-approve ); \
			echo "==============================================="; \
		else \
			echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
		fi \
	done

# ========================================================
# Output
# ========================================================
.PHONY: output
output: install
	@set -x; for module in $(MODULES); do \
		if [ -n "$(ENV)" ] && [ "$$module" != "$(ENV)" ]; then continue; fi; \
		MODULE_PATH="$(TG_BASE_DIR)/$$module"; \
		if [ -d "$$MODULE_PATH" ]; then \
			echo "==============================================="; \
			echo "Fetching outputs from $$MODULE_PATH"; \
			( cd "$$MODULE_PATH" && \
			  PATH=$(BIN_DIR):$$PATH terragrunt output ); \
			echo "==============================================="; \
		else \
			echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
		fi \
	done

# ========================================================
# Clean
# ========================================================
.PHONY: clean
clean:
	rm -rf $(BIN_DIR)
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} +
