# ========================================================
# Makefile for Terragrunt Infrastructure (Safe ENV Filtering)
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
# Helper: Run a command in a module safely
# ========================================================
define run_module
MODULE_PATH="$(TG_BASE_DIR)/$1"; \
if [ -d "$$MODULE_PATH" ]; then \
    echo "==============================================="; \
    echo "[INFO] Running $2 in $$MODULE_PATH"; \
    echo "[DEBUG] ENV=$(ENV), Module=$1"; \
    ( cd "$$MODULE_PATH" && rm -rf .terragrunt-cache || true && PATH=$(BIN_DIR):$$PATH terragrunt $2 ); \
    echo "==============================================="; \
else \
    echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
fi
endef

# ========================================================
# Install Terraform & Terragrunt
# ========================================================
.PHONY: install
install:
	@mkdir -p $(BIN_DIR)
	@if [ ! -f $(TERRAFORM_BIN) ]; then \
		echo "Installing Terraform v$(TERRAFORM_VERSION)..."; \
		curl -L -o $(BIN_DIR)/terraform.zip https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_$(TERRAFORM_OS).zip; \
		unzip -o $(BIN_DIR)/terraform.zip -d $(BIN_DIR); \
		chmod +x $(TERRAFORM_BIN); \
	fi
	@$(TERRAFORM_BIN) --version

	@if [ ! -f $(TERRAGRUNT_BIN) ]; then \
		echo "Installing Terragrunt v$(TERRAGRUNT_VERSION)..."; \
		curl -L -o $(TERRAGRUNT_BIN) https://github.com/gruntwork-io/terragrunt/releases/download/v$(TERRAGRUNT_VERSION)/terragrunt_$(TERRAGRUNT_OS); \
		chmod +x $(TERRAGRUNT_BIN); \
	fi
	@$(TERRAGRUNT_BIN) --version

# ========================================================
# Plan
# ========================================================
.PHONY: plan
plan: install
	@for module in $(MODULES); do \
		if [ "$$module" = "$(ENV)" ]; then \
			$(call run_module,$$module,"init -reconfigure && plan"); \
		else \
			echo "[DEBUG] Skipping module $$module (ENV=$(ENV))"; \
		fi \
	done

# ========================================================
# Apply
# ========================================================
.PHONY: apply
apply: install
	@for module in $(MODULES); do \
		if [ "$$module" = "$(ENV)" ]; then \
			$(call run_module,$$module,"apply -auto-approve"); \
		else \
			echo "[DEBUG] Skipping module $$module (ENV=$(ENV))"; \
		fi \
	done

# ========================================================
# Destroy
# ========================================================
.PHONY: destroy
destroy: install
	@for module in $(MODULES); do \
		if [ "$$module" = "$(ENV)" ]; then \
			$(call run_module,$$module,"destroy -auto-approve"); \
		else \
			echo "[DEBUG] Skipping module $$module (ENV=$(ENV))"; \
		fi \
	done

# ========================================================
# Output
# ========================================================
.PHONY: output
output: install
	@for module in $(MODULES); do \
		if [ "$$module" = "$(ENV)" ]; then \
			$(call run_module,$$module,"output"); \
		else \
			echo "[DEBUG] Skipping module $$module (ENV=$(ENV))"; \
		fi \
	done

# ========================================================
# Clean
# ========================================================
.PHONY: clean
clean:
	rm -rf $(BIN_DIR)
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} +
