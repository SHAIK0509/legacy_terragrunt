MAKEOPTS += --no-print-directory
.DEFAULT_GOAL := help

export ECR_URL
export APP_BUILD_NUMBER

export ENVIRONMENT := $(if $(ENV),$(ENV),dev)
export COMPOSE_FILE := ../docker-compose.ci.yml
export COMPOSE_PROJECT_NAME := auth_depot

################################################################################
# LOCAL DEVELOPMENT ONLY
#
ifndef JENKINS_ENVIRONMENT
# We're running locally, so we must setup several
# env vars that will already be present when running in jenkins.
export CMD
# aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 165446266030.dkr.ecr.us-east-1.amazonaws.com
# docker build -t auth_depot .
# docker tag auth_depot:latest 165446266030.dkr.ecr.us-east-1.amazonaws.com/auth_depot:latest
# docker push 165446266030.dkr.ecr.us-east-1.amazonaws.com/auth_depot:latest
# in Jenkins we want to be able to checkout a commit,  make it default to masterif there is no branch.
export myBRANCH = $(shell git branch --show-current)
export BRANCH = $(if $(myBRANCH),$(myBRANCH),master)
export APP_BUILD_NUMBER = $(BRANCH)-$(shell git rev-parse --short HEAD)

AWS_AUTH_TARGETS := deploy publish _auth destroy output terragrunt
# Avoid these slow shell calls unless they are needed for the target called.
# If at some point a target needs access to AWS resrouces (e.g. `make test`)
# during local development, add the target name to AWS_AUTH_TARGETS.
ifneq (,$(strip $(foreach goal,$(MAKECMDGOALS),$(findstring $(goal),$(AWS_AUTH_TARGETS)))))
export AWS_PROFILE := $(ENVIRONMENT)

# export AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text --profile $(AWS_PROFILE))
# export ECR_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text --profile shared-services)

export AWS_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text)
export ECR_ACCOUNT_ID = $(shell aws sts get-caller-identity --query 'Account' --output text)
export ECR_DOMAIN = $(ECR_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com
export ECR_URL = $(ECR_DOMAIN)/
endif


_auth:
	@echo '--> Signing in to ECR: $(ECR_DOMAIN)'
	aws ecr get-login-password --region us-east-1  | \
		docker login --username AWS --password-stdin $(ECR_DOMAIN)
.PHONY: _auth

publish: | _auth
endif
################################################################################

ifdef JENKINS_ENVIRONMENT
# This is a temporary workaround for lack of ssh-keys on the deploy agent
USERCREDS := $(if $(GIT_CREDS_USR),$(GIT_CREDS_USR):$(GIT_CREDS_PSW)@)
export TERRAGRUNT_SOURCE := git::https://$(USERCREDS)github.com$(shell sed -En 's| +source = "git::ssh://git@github.com(.+)"|\1|p' terragrunt.hcl)
endif


build: ## Builds the app's docker image
	@echo '--> Building $(ECR_URL)$(COMPOSE_PROJECT_NAME):$(APP_BUILD_NUMBER)'
	cd .. & docker compose -f $(COMPOSE_FILE) build
.PHONY: build

shell: | build  ## Launches a shell session on a running the app's container
	docker compose -f $(COMPOSE_FILE) run --rm app bash
.PHONY:

start: | build  ## Starts the compose stack
	@echo '---> Starting the $(COMPOSE_PROJECT_NAME) compose stack'
	docker compose -f $(COMPOSE_FILE) up -d
.PHONY: start

start-app: | start  ## Starts the entrypoint process in the running stack
	@echo '---> Starting the $(COMPOSE_PROJECT_NAME) compose stack'
	docker compose -f $(COMPOSE_FILE) exec app /wait || true
	docker compose -f $(COMPOSE_FILE) exec app make gunicorn || true
	@make stop
.PHONY: start-app

stop:  ## Stops the compose stack
	docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans
.PHONY: stop

test: export DOCKER_COMPOSE_CMD := docker compose -f $(COMPOSE_FILE) exec -T app
test: | start  ## Runs tests against the image
	@echo '--> Testing $(ECR_URL)$(COMPOSE_PROJECT_NAME):$(APP_BUILD_NUMBER)'
# 	$(DOCKER_COMPOSE_CMD) /wait
# 	$(DOCKER_COMPOSE_CMD) pipenv sync --dev --bare
# 	$(DOCKER_COMPOSE_CMD) pipenv run make lint
# 	$(DOCKER_COMPOSE_CMD) pipenv run make test
	@make stop
.PHONY: test

publish: | build  ## Publishes the app image to ECR
	@echo '--> Publishing $(ECR_URL)perseus:$(APP_BUILD_NUMBER)'
	$(if $(DRYRUN),@echo "-->" WOULD RUN ) docker compose -f $(COMPOSE_FILE) push app

deploy:  ## Deploys the app service to ECS Fargate
	@echo '--> Deploying $(ECR_URL)perseus:$(APP_BUILD_NUMBER) to $(ENVIRONMENT)'
	@rm -rf .terragrunt-cache
	pwd
	ls
	
# 	terragrunt plan -out $(COMPOSE_PROJECT_NAME).plan
	$(if $(DRYRUN),@echo "-->" WOULD RUN )terragrunt apply -auto-approve $(COMPOSE_PROJECT_NAME).plan

output:  ## Prints the outputs in terraform state
	@terragrunt output -json -no-color all 2> ./.terragrunt.output || \
		( echo '--- STDERR ---'; "$$(cat ./.terragrunt.output)"; exit 1 )

terragrunt:  ## Runs a terragrunt command with ARGS in the deployment context
	terragrunt $(ARGS)

destroy:  ## Destroys the service (dev only)
	@if [ "$${ENVIRONMENT}" != "dev" ]; then \
		echo "Refusing to destroy the $${COMPOSE_PROJECT_NAME} service in $${ENVIRONMENT}"; \
		exit 1; \
	fi
	@echo '--> Destroying the $${COMPOSE_PROJECT_NAME} service in $${ENVIRONMENT}'
	@rm -rf .terragrunt-cache
	@terragrunt destroy

clean:  ## Removes compose artifacts
	docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans --rmi=local
	rm -rf ./.terragrunt-cache
.PHONY: clean

help: ## Display this help section
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-38s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
.PHONY: help