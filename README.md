# Flutter Clean App

Flutter application built with Clean Architecture, BLoC pattern and Docker support.

## Tech Stack

- **Flutter** 3.22.0 / **Dart** >=3.3.0
- **BLoC** — state management
- **GetIt** — dependency injection
- **Dio** — HTTP client
- **Go Router** — navigation
- **Dartz** — functional programming (Either)
- **Docker** — containerized dev environment

---

## Prerequisites

### Local (sem Docker)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.22.0
- Dart >= 3.3.0

### Com Docker
- [Docker](https://docs.docker.com/get-docker/) e Docker Compose
- `make` (opcional, mas recomendado)

---

## Rodando localmente (sem Docker)

```bash
# Instalar dependências
flutter pub get

# Rodar no dispositivo/emulador conectado
flutter run

# Rodar na web
flutter run -d chrome

# Rodar como web server (porta 8080)
flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

---

## Rodando com Docker

### 1. Build da imagem

```bash
make build
# ou
docker compose build
```

### 2. Subir o container de desenvolvimento

```bash
make up
# ou
docker compose up -d flutter_dev
```

### 3. Instalar dependências dentro do container

```bash
make get
# ou
docker compose exec flutter_dev flutter pub get
```

### 4. Rodar o app

**Web (acesse em http://localhost:8080):**
```bash
make run-web
# ou
docker compose exec flutter_dev flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
```

**Android (requer dispositivo/emulador conectado via ADB):**
```bash
make run-android
# ou
docker compose exec flutter_dev flutter run -d android
```

**Modo web com Docker Compose profile:**
```bash
docker compose --profile web up flutter_web
```

### 5. Parar os containers

```bash
make down
# ou
docker compose down
```

---

## Build de Release

```bash
# Web
make build-web
# ou: flutter build web --release

# APK Android
make build-apk
# ou: flutter build apk --release

# App Bundle (Google Play)
make build-appbundle
# ou: flutter build appbundle --release
```

---

## Outros comandos úteis

| Comando | Descrição |
|---|---|
| `make shell` | Abre bash dentro do container |
| `make test` | Roda todos os testes com coverage |
| `make lint` | Analisa o código (`flutter analyze`) |
| `make format` | Formata o código (`dart format`) |
| `make fix` | Aplica auto-fix de lint (`dart fix --apply`) |
| `make clean` | Limpa artefatos e reinstala dependências |
| `make gen` | Roda o `build_runner` |
| `make gen-watch` | Roda o `build_runner` em modo watch |
| `make help` | Lista todos os comandos disponíveis |

---

## Testes

```bash
# Local
flutter test --coverage

# Com Docker
make test
```

---

## Estrutura do projeto

```
lib/
├── core/           # Configurações globais, erros, utilitários
├── features/       # Funcionalidades por domínio (Clean Architecture)
│   └── feature/
│       ├── data/       # Repositórios, datasources, models
│       ├── domain/     # Entities, use cases, interfaces
│       └── presentation/ # BLoC, pages, widgets
└── main.dart
```
