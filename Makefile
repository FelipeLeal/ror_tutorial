.DEFAULT_GOAL := help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: up
up: ## run the project
	@docker-compose run --service-ports --rm store_ror || true

.PHONY: stop
stop: ## stop Docker containers without removing them
	@docker-compose stop

.PHONY: down
down: ## stop and remove Docker containers
	@docker-compose down --remove-orphans

.PHONY: rebuild
rebuild: down ## rebuild base Docker images
	@docker-compose build --no-cache

.PHONY: reset
reset: ## update Docker images and reset local databases
	@docker-compose down --volumes --remove-orphans
	@docker-compose pull

.PHONY: pull
pull: down ## update Docker images without losing local databases
	@docker-compose pull

.PHONY: fromscratch
fromscratch: reset pull up

.PHONY: bash
bash: ## drops you into a running container
	@docker exec -it -e RUNTYPE=bash $$(docker ps|grep store-store_ror|awk '{ print $$1 }') bash || true

.PHONY: rootbash
rootbash: ## drops you into a running container as root
	@docker exec -it -e RUNTYPE=bash --user=root $$(docker ps|grep store-store_ror|awk '{ print $$1 }') bash || true

.PHONY: console
console: ## drops you into a running container
	@docker exec -it -e RUNTYPE=bash $$(docker ps|grep store-store_ror|awk '{ print $$1 }') bin/rails console || true
