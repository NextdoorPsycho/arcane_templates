# Server Template

Backend server template for Flutter applications. Built with Shelf router, Firebase Admin SDK, and Docker containerization.

## Overview

Production-ready Flutter server providing REST API endpoints, server-side Firestore operations, and Google Cloud Storage integration.

**Features:**
- REST API with Shelf router
- Firebase Admin (server-side Firestore/Storage access)
- Request authentication (signature-based with timing attack protection)
- Services layer (business logic separated from API)
- Docker containerization
- Google Cloud Run deployment scripts

## Structure

```
lib/
├── main.dart                  # Server entry, routing
├── api/                       # API endpoint handlers
│   ├── user_api.dart
│   ├── settings_api.dart
│   └── command_api.dart
├── service/                   # Business logic
│   ├── user_service.dart
│   ├── command_service.dart
│   └── media_service.dart
└── util/
    └── request_authenticator.dart # Auth middleware

Dockerfile                     # Production container
script_deploy.sh              # Cloud Run deployment
```

## Quick Start

**Run locally:**
```bash
flutter run -d linux
```

**Run in Docker (development):**
```bash
docker build -f Dockerfile-dev -t server-dev .
docker run -p 8080:8080 server-dev
```

Server starts on `http://localhost:8080`

**Test endpoints:**
```bash
# Health check
curl http://localhost:8080/keepAlive

# Server info
curl http://localhost:8080/info
```

## API Endpoints

### System Endpoints

**GET /keepAlive** - Health check for Cloud Run
**GET /info** - Server version and config info

### User API (/api/user)

**GET /api/user/info/<userId>** - Get user information
**POST /api/user/update/<userId>** - Update user
**GET /api/user/list** - List users with pagination

### Settings API (/api/settings)

**GET /api/settings/<userId>** - Get user settings
**POST /api/settings/<userId>/theme** - Update theme preference

### Command API (/api/command)

**POST /api/command/execute** - Execute server command
**GET /api/command/status/<commandId>** - Get command status

All API endpoints (except system endpoints) require authentication headers:
- `x-user-id` - User ID
- `x-signature-hash` - HMAC signature

## Services Layer

Services contain business logic, keeping API handlers thin.

**UserService** - User CRUD operations
**CommandService** - Server command processing
**MediaService** - Google Cloud Storage file management

**Access pattern:**
```dart
final user = await APPNAMEServer.svcUser.getUser(userId);
```

## Authentication

Signature-based authentication with timing attack protection.

**Required headers:**
```
x-user-id: user123
x-signature-hash: generated_signature
```

**Backend key auth** (/backend/*):
```
x-backend-key: YOUR_BACKEND_KEY
```

**GCP event auth** (/event/*):
```
Authorization: Bearer JWT_TOKEN
```

**Update keys:**

Edit `lib/util/request_authenticator.dart`:
```dart
static const String _backendKey = "your-secure-backend-key";
```

## Docker

### Production Build

Multi-stage build for minimal image size (~50MB runtime):

```bash
docker build --platform linux/amd64 -t server .
```

### Development Build

Includes Flutter SDK for debugging:

```bash
docker build -f Dockerfile-dev -t server-dev .
docker run -p 8080:8080 -v $(pwd):/app server-dev
```

## Deployment

### Prerequisites

1. Google Cloud Project with:
   - Artifact Registry repository
   - Cloud Run API enabled
   - Service account with Firestore/Storage permissions

2. Local tools:
   - Docker installed
   - gcloud CLI authenticated
   - Firebase service account key in `config/keys/`

### Automated Deployment

```bash
./script_deploy.sh
```

Script performs:
1. Copies models directory
2. Builds Docker image (linux/amd64)
3. Tags for Artifact Registry
4. Pushes to Google Cloud
5. Deploys to Cloud Run

### Manual Deployment

```bash
# Copy models
cp -r ../APPNAME_models ./

# Build image
docker build --platform linux/amd64 -t server .

# Tag for registry
docker tag server \
  us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/server:latest

# Push
docker push us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/server:latest

# Deploy
gcloud run deploy server \
  --image us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/server:latest \
  --region us-central1 \
  --memory 1Gi \
  --cpu 1 \
  --set-env-vars GOOGLE_CLOUD_PROJECT=PROJECT_ID \
  --allow-unauthenticated
```

### Environment Variables

Set in Cloud Run:

| Variable | Value | Purpose |
|----------|-------|---------|
| GOOGLE_CLOUD_PROJECT | Your project ID | Firebase/GCS auth |
| PORT | 8080 | Server port (auto-set) |
| ENVIRONMENT | production | Environment flag |

### Configuration

**Update placeholders:**

1. `lib/main.dart` - Bucket name:
```dart
APPNAMEServer.svcMedia.initialize("FIREBASE_PROJECT_ID.appspot.com");
```

2. `lib/util/request_authenticator.dart` - Backend key:
```dart
static const String _backendKey = "your-secure-key";
```

3. `script_deploy.sh` - Project settings:
```bash
PROJECT_ID="your-project-id"
REGION="us-central1"
REGISTRY="your-registry"
```

## Adding New Endpoints

**Step 1:** Create API class (`lib/api/my_api.dart`):

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../main.dart';

class MyAPI implements Routing {
  @override
  String get prefix => "/api/my";

  @override
  Router get router => Router()
    ..get("/hello", _hello);

  Future<Response> _hello(Request request) async {
    return Response.ok(
      jsonEncode({"message": "Hello"}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

**Step 2:** Register in `lib/main.dart`:

```dart
class APPNAMEServer implements Routing {
  static late MyAPI apiMy;

  Future<void> _startAPIs() async {
    apiUser = UserAPI();
    apiMy = MyAPI();  // Add API
  }

  @override
  Router get router => Router()
    ..mount(apiUser.prefix, apiUser.router.call)
    ..mount(apiMy.prefix, apiMy.router.call)  // Mount API
    ..get("/keepAlive", _requestGetKeepAlive);
}
```

**Step 3:** Test:

```bash
curl http://localhost:8080/api/my/hello
```

## Adding New Services

**Step 1:** Create service (`lib/service/my_service.dart`):

```dart
import 'package:fast_log/fast_log.dart';

class MyService {
  Future<String> processData(Map<String, dynamic> data) async {
    try {
      verbose("Processing data: $data");
      final result = "processed";
      return result;
    } catch (e) {
      error("Failed to process: $e");
      rethrow;
    }
  }
}
```

**Step 2:** Register in `lib/main.dart`:

```dart
class APPNAMEServer {
  static late MyService svcMy;

  Future<void> _startServices() async {
    svcUser = UserService();
    svcMy = MyService();  // Add service
  }
}
```

**Step 3:** Use in APIs:

```dart
final result = await APPNAMEServer.svcMy.processData(data);
```

## Logging

Uses fast_log package:

```dart
verbose("Detailed info");
info("General info");
warn("Potential issues");
error("Errors");
fatal("Critical errors");
```

Configure log level in `lib/main.dart`:

```dart
Logger.level = LogLevel.verbose; // or info, warn, error
```

## Testing

**Unit tests:**

```dart
import 'package:test/test.dart';
import 'package:APPNAME_server/service/user_service.dart';

void main() {
  group('UserService', () {
    test('gets user by ID', () async {
      final service = UserService();
      final user = await service.getUser('test_user');
      expect(user, isNotNull);
    });
  });
}
```

**Integration tests:**

```dart
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';

void main() {
  group('User API', () {
    test('returns user', () async {
      final api = UserAPI();
      final request = Request('GET', Uri.parse('/api/user/info/user123'));
      final response = await api._getUserInfo(request, 'user123');
      expect(response.statusCode, 200);
    });
  });
}
```

## Troubleshooting

**Server won't start:**

Check port: `lsof -i :8080` and kill if needed.
Verify Firebase credentials: `ls config/keys/service-account.json`

**Docker build fails:**

Specify platform: `docker build --platform linux/amd64 -t server .`
Clean up: `docker system prune -a`

**Cloud Run deployment fails:**

Check authentication: `gcloud auth list`
Set project: `gcloud config set project PROJECT_ID`
Verify permissions and API enabled in console.

**Authentication fails:**

Use same secret key on client and server.
Include timestamp in signature (prevents replay attacks).
Use HMAC SHA-256.

## Dependencies

| Package | Purpose |
|---------|---------|
| shelf | HTTP server framework |
| shelf_router | Request routing |
| arcane_admin | Firebase Admin SDK wrapper |
| google_cloud | GCS file operations |
| APPNAME_models | Shared data models |
| crypto | Signature verification |
| fast_log | Structured logging |

## Best Practices

**1. Separate concerns** - Keep API handlers thin, move logic to services.

**2. Error handling** - Always catch and log errors, return appropriate HTTP status codes.

**3. Input validation** - Validate all input data, check required fields and formats.

**4. Use middleware** - Add common functionality (CORS, auth) via middleware.

**5. Secure data** - Never log sensitive information (passwords, keys, tokens).

## Documentation

- [Main README](../README.md) - Project overview
- [Models Template](../models_template/README.md) - Shared models guide
- [Firebase Documentation](https://firebase.google.com/docs) - Firebase features
- [Cloud Run Documentation](https://cloud.google.com/run/docs) - Deployment guide
- [Shelf Documentation](https://pub.dev/packages/shelf) - HTTP server framework

## Related Templates

- **arcane_template** - Client application template
- **arcane_beamer** - Client with Beamer navigation
- **arcane_dock** - System tray application
- **models_template** - Shared data models

See [main README](../README.md) for details.
