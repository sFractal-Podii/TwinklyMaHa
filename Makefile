# Configuration
	# -------------

APP_NAME ?= `grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g'`
APP_VERSION := $(shell grep 'version:' mix.exs | cut -d '"' -f2)
DOCKER_IMAGE_TAG ?= $(APP_VERSION)
GIT_REVISION ?= `git rev-parse HEAD`
CLIENT_ID=:sfractal2020
MQTT_HOST=34.86.117.113
MQTT_PORT=1883
USER_NAME=plug
PASSWORD=fest

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo  "\033[34mEnvironment\033[0m"
	@echo  "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "APP_VERSION"
	@printf "\033[35m%s\033[0m" $(APP_VERSION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "DOCKER_IMAGE_TAG"
	@printf "\033[35m%s\033[0m" $(DOCKER_IMAGE_TAG)
	@echo "\n"

.PHONY: targets
targets:
	@echo  "\033[34mTargets\033[0m"
	@echo  "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: compile
compile: ## compile the project
	mix compile

.PHONY: lint-compile
lint-compile: ## check for warnings in functions used in the project
	mix compile --warnings-as-errors --force

.PHONY: lint-format
lint-format: ## Check if the project is well formated using elixir formatter
	mix format --dry-run --check-formatted

.PHONY: lint-credo
lint-credo: ## Use credo to ensure formatting styles
	mix credo --strict

.PHONY: lint
lint: lint-compile lint-format lint-credo ## Check if the project follows set conventions such as formatting


.PHONY: test
test: ## Run the test suite
	mix test

.PHONY: format
format: mix format ## Run formatting tools on the code


release: ## Build a release of the application with MIX_ENV=prod
	MIX_ENV=prod mix deps.get --only prod
	MIX_ENV=prod mix compile
	npm install --prefix ./assets
	npm run deploy --prefix ./assets
	mkdir -p priv/static
	MIX_ENV=prod mix phx.digest
	MIX_ENV=prod mix release

.PHONY: docker-image
docker-image:
	docker build . -t maha:$(APP_VERSION) --no-cache \
	--build-arg CLIENT_ID=$(CLIENT_ID) \
	--build-arg MQTT_HOST=$(MQTT_HOST) \
	--build-arg MQTT_PORT=$(MQTT_PORT) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg PASSWORD=$(PASSWORD) \

.PHONY: push-image-gcp push-and-serve deploy-existing-image
push-image-gcp: ## push image to gcp
	@if [[ "$(docker images -q gcr.io/twinklymaha/maha:$(APP_VERSION)> /dev/null)" != "" ]]; then \
  @echo "Removing previous image $(APP_VERSION) from your machine..."; \
	docker rmi gcr.io/twinklymaha/maha:$(APP_VERSION);\
	fi
	docker build . -t gcr.io/twinklymaha/maha:$(APP_VERSION) --no-cache \
	--build-arg CLIENT_ID=$(CLIENT_ID) \
	--build-arg MQTT_HOST=$(MQTT_HOST) \
	--build-arg MQTT_PORT=$(MQTT_PORT) \
	--build-arg USER_NAME=$(USER_NAME) \
	--build-arg PASSWORD=$(PASSWORD) \

	gcloud container images delete gcr.io/twinklymaha/maha:$(APP_VERSION) --force-delete-tags  || echo "no image to delete on the remote"
	docker push gcr.io/twinklymaha/maha:$(APP_VERSION)

push-and-serve-gcp: push-image-gcp deploy-existing-image

deploy-existing-image:
	gcloud compute instances create-with-container $(instance-name) \
		--container-image=gcr.io/twinklymaha/maha:$(DOCKER_IMAGE_TAG) \
		--machine-type=e2-micro \
		--subnet=default \
		--network-tier=PREMIUM \
		--metadata=google-logging-enabled=true \
		--tags=http-server,https-server \
		--labels=project=twinklymaha \
		--container-env=CLIENT_ID=$(CLIENT_ID),MQTT_HOST=$(MQTT_HOST),MQTT_PORT=$(MQTT_PORT),USER_NAME=$(USER_NAME),PASSWORD=$(PASSWORD)

.PHONY: update-instance
update-instance:
	gcloud compute instances update-container $(instance-name) --container-image gcr.io/twinklymaha/maha:$(image-tag)
