.PHONY: build

TIMESTAMP=$(shell date +%s)

SERVICE_NAME="spinnaker-cd-deployment"
HELM_CHART_PATH = "build/charts/$(SERVICE_NAME)/"

ECR_REPO_URL="861597889956.dkr.ecr.us-east-1.amazonaws.com/$(SERVICE_NAME)"

ifeq ($(strip $(DOCKER_COMPOSE_FILE)),)
DOCKER_COMPOSE_FILE="docker-compose.yml"
endif

ifeq ($(strip $(TAG)),)
TAG="dev-$(TIMESTAMP)"
endif

ifeq ($(strip $(BUILD_NUMBER)),)
BUILD_NUMBER="dev-$(TIMESTAMP)"
endif

ifeq ($(strip $(NAMESPACE)),)
NAMESPACE="$(SERVICE_NAME)-$(TAG)"
endif

helm-lint:
	helm dep up $(HELM_CHART_PATH)
	helm lint $(HELM_CHART_PATH)
helm-dry-run:
	helm install --name=$(SERVICE_NAME)-dry-run --namespace=$(SERVICE_NAME)-dry-run $(HELM_CHART_PATH) --dry-run --debug
ecr-login:
	aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(ECR_REPO_URL)
build: ecr-login
	docker build -t $(SERVICE_NAME):latest \
	 --build-arg BUILD_NUMBER=$(BUILD_NUMBER) \
	 --build-arg BUILD_URL=$(BUILD_URL) \
	 --build-arg GIT_COMMIT=$(GIT_COMMIT) \
	 --build-arg GIT_URL=$(GIT_URL) \
	 --build-arg GIT_BRANCH=$(GIT_BRANCH) .
push: build
	docker tag $(SERVICE_NAME):latest $(ECR_REPO_URL):$(TAG)
	docker push $(ECR_REPO_URL):$(TAG)
unit-test-environment-up:
	echo "skip"
unit-test-environment-down:
	echo "skip"
unit-test-run:
	echo "skip"
unit-test-export-results:
	echo "skip"
integration-test-environment-up:
	echo "skip"
integration-test-environment-down:
	echo "skip"
integration-test-run:
	echo "skip"
integration-test-get-world-url:
	echo "skip"
code-analysis-check:
	echo "skip"
style-check:
	echo "skip"
security-check:
	echo "skip"