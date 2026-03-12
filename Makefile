.PHONY: help build up down shell get run-web run-android test lint format fix clean gen build-web build-apk

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker image
	docker compose build

up: ## Start dev container
	docker compose up -d flutter_dev

down: ## Stop all containers
	docker compose down

shell: ## Open shell in container
	docker compose exec flutter_dev bash

get: ## Get pub dependencies
	docker compose exec flutter_dev flutter pub get

run-web: ## Run on web (port 8080)
	docker compose exec flutter_dev flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0

run-android: ## Run on Android device
	docker compose exec flutter_dev flutter run -d android

test: ## Run all tests
	docker compose exec flutter_dev flutter test --coverage

lint: ## Run flutter analyze
	docker compose exec flutter_dev flutter analyze

format: ## Format code
	docker compose exec flutter_dev dart format lib test

fix: ## Auto-fix lint issues
	docker compose exec flutter_dev dart fix --apply

clean: ## Clean build artifacts
	docker compose exec flutter_dev flutter clean && docker compose exec flutter_dev flutter pub get

gen: ## Run build_runner
	docker compose exec flutter_dev dart run build_runner build --delete-conflicting-outputs

gen-watch: ## Run build_runner watch
	docker compose exec flutter_dev dart run build_runner watch --delete-conflicting-outputs

build-web: ## Build web release
	docker compose exec flutter_dev flutter build web --release

build-apk: ## Build APK release
	docker compose exec flutter_dev flutter build apk --release

build-appbundle: ## Build App Bundle
	docker compose exec flutter_dev flutter build appbundle --release
