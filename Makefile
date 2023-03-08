ifeq ($(OS),Windows_NT)
	SHELL := pwsh.exe
else
	SHELL := pwsh
endif

.SHELLFLAGS := -NoProfile -Command

getcommitid: 
	$(eval COMMITID = $(shell git log -1 --pretty=format:"%H"))
getbranchname:
	$(eval BRANCH_NAME = $(shell (git branch --show-current ) -replace '/','.'))


.PHONY: all clean test lint act
all: test

REGISTRY_NAME := 
REPOSITORY_NAME := bmcclure89/
IMAGE_NAME := ustaxes
TAG := :latest

# Run Options
RUN_PORTS := -p 3000:3000

build: getcommitid getbranchname
	docker build -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME) -t $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME):$(BRANCH_NAME)_$(COMMITID) .


run: build
	docker run -d $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

run_it:
	docker run -it $(RUN_PORTS) $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

package:
	$$PackageFileName = "$$("$(IMAGE_NAME)" -replace "/","_").tar"; docker save $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG) -o $$PackageFileName

size:
	docker inspect -f "{{ .Size }}" $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)
	docker history $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG)

publish:
	docker login; docker push $(REGISTRY_NAME)$(REPOSITORY_NAME)$(IMAGE_NAME)$(TAG); docker logout
