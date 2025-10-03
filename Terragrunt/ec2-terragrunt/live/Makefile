# ========================================================
# Makefile for Terragrunt Infrastructure
# Repo: legacy_terragrunt/terragrunt/ec2-terragrunt
# ========================================================

TERRAFORM_VERSION ?= 0.13.6
TERRAGRUNT_VERSION ?= 0.27.1
TERRAFORM_BIN := $(CURDIR)/terraform
TERRAGRUNT_BIN := $(CURDIR)/terragrunt

# Modules to manage
MODULES := dev prod stage
ENV ?= dev  # default environment
TG_BASE_DIR := $(CURDIR)

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
# Plan for all modules (safe, skips missing directories)
# ========================================================
define run_module
MODULE_PATH="$(TG_BASE_DIR)/$1"; \
if [ -d "$$MODULE_PATH" ]; then \
    echo "==============================================="; \
    echo "[INFO] Running $2 in $$MODULE_PATH"; \
    echo "[DEBUG] ENV=$(ENV), Module=$1"; \
    ( cd "$$MODULE_PATH" && rm -rf .terragrunt-cache || true && PATH=$(BIN_DIR):$$PATH $(TERRAGRUNT_BIN) $2 ); \
    echo "==============================================="; \
else \
    echo "[ERROR] Directory $$MODULE_PATH does not exist, skipping..."; \
    exit 1; \
fi
endef


.PHONY: plan
plan: install
	@set -x; \
	MODULE_PATH="$(TG_BASE_DIR)/$(ENV)"; \
	if [ -d "$$MODULE_PATH" ]; then \
		echo "==============================================="; \
		echo "[INFO] Running plan in $$MODULE_PATH"; \
		( cd "$$MODULE_PATH" && rm -rf .terragrunt-cache || true && PATH=$(BIN_DIR):$$PATH terragrunt init -reconfigure && PATH=$(BIN_DIR):$$PATH terragrunt plan ); \
		echo "==============================================="; \
	else \
		echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
	fi

# ========================================================
# Apply for selected ENV only
# ========================================================
.PHONY: apply
apply: install
	@set -x; \
	MODULE_PATH="$(TG_BASE_DIR)/$(ENV)"; \
	echo "[DEBUG] Checking module: $(ENV) at $$MODULE_PATH"; \
	if [ -d "$$MODULE_PATH" ]; then \
		echo "==============================================="; \
		echo "Running terragrunt apply in $$MODULE_PATH"; \
		ls -l "$$MODULE_PATH"; \
		( cd "$$MODULE_PATH" && \
		  rm -rf .terragrunt-cache || true && \
		  which terragrunt; \
		  PATH=$(CURDIR):$$PATH terragrunt apply -auto-approve ); \
		echo "==============================================="; \
	else \
		echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
	fi

# ========================================================
# Destroy for selected ENV only
# ========================================================
.PHONY: destroy
destroy: install
	@set -x; \
	MODULE_PATH="$(TG_BASE_DIR)/$(ENV)"; \
	echo "[DEBUG] Checking module: $(ENV) at $$MODULE_PATH"; \
	if [ -d "$$MODULE_PATH" ]; then \
		echo "==============================================="; \
		echo "Running terragrunt destroy in $$MODULE_PATH"; \
		ls -l "$$MODULE_PATH"; \
		( cd "$$MODULE_PATH" && \
		  rm -rf .terragrunt-cache || true && \
		  which terragrunt; \
		  PATH=$(CURDIR):$$PATH terragrunt destroy -auto-approve ); \
		echo "==============================================="; \
	else \
		echo "[WARNING] Directory $$MODULE_PATH does not exist, skipping..."; \
	fi
# ========================================================
# Output for all modules
# ========================================================
.PHONY: output
output: install
	@set -x; for module in $(MODULES); do \
		MODULE_PATH="$(TG_BASE_DIR)/$$module"; \
		echo "[DEBUG] Checking module: $$module at $$MODULE_PATH"; \
		if [ -d "$$MODULE_PATH" ]; then \
			echo "==============================================="; \
			echo "Fetching outputs from $$MODULE_PATH"; \
			ls -l "$$MODULE_PATH"; \
			( cd "$$MODULE_PATH" && \
			  which terragrunt; \
			  PATH=$(CURDIR):$$PATH terragrunt output ); \
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
	rm -f terraform terraform.zip terragrunt
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} +

