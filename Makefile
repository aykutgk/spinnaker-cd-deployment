.PHONY: build

TIMESTAMP=$(shell date +%s)

SERVICE_NAME="spinnaker-cd-deployment"
HELM_CHART_PATH = "build/chart/$(SERVICE_NAME)/"

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
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
	docker-compose -f $(DOCKER_COMPOSE_FILE) up --build -d
unit-test-environment-down:
	docker-compose -f $(DOCKER_COMPOSE_FILE) down
unit-test-run:
	docker-compose -f $(DOCKER_COMPOSE_FILE) exec -T $(SERVICE_NAME) /test.sh
unit-test-export-results:
	echo "skip"
integration-test-environment-up:
	helm install cbchartrepo/worldbuilder.clientapp_pr --name $(NAMESPACE) --namespace $(NAMESPACE) --set authservice.tag=$(TAG) --set authservice.replicas=1 --set authservice.memory_limit="4Gi" --set authservice.cpu_limit="2"  --set gateway.elb_enabled=true --set workflowservice-background-worker.replicas=0 --wait --timeout 1500
integration-test-environment-down:
	helm delete $(NAMESPACE) --purge --timeout 1500
integration-test-run:
	kubectl exec deploy/$(SERVICE_NAME) /test.sh -n $(NAMESPACE)
integration-test-get-world-url:
	kubectl get svc gateway-elb -n $(NAMESPACE) -o jsonpath='{.status.loadBalancer.ingress[*].hostname}'
code-analysis-check:
	echo "skip"
style-check:
	echo "skip"
security-check:
	echo "skip"