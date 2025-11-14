# APPNAME Server

Backend server for APPNAME built with Flutter and Shelf.

## Structure

```
lib/
├── main.dart              # Server entry point and routing
├── api/                   # API endpoint handlers
│   ├── user_api.dart     # User management endpoints
│   ├── settings_api.dart # Settings endpoints
│   └── command_api.dart  # Command execution endpoints
├── service/              # Business logic services
│   ├── user_service.dart     # User service
│   ├── command_service.dart  # Command processing
│   └── media_service.dart    # Media/file management
└── util/                 # Utilities
    └── request_authenticator.dart  # Authentication middleware
```

## Features

- **Shelf Router**: HTTP routing and middleware
- **Firebase Integration**: Firestore via ArcaneAdmin
- **Google Cloud Storage**: Media file management
- **Authentication**: Signature-based request auth with timing attack protection
- **CORS**: Configured for cross-origin requests
- **Docker**: Production-ready containerization

## Running Locally

```bash
flutter run -d linux
```

The server will start on port 8080 by default.

## API Endpoints

### User API (`/api/user`)
- `GET /info/<userId>` - Get user information
- `POST /update/<userId>` - Update user
- `GET /list?limit=10&offset=0` - List users (paginated)

### Settings API (`/api/settings`)
- `GET /<userId>` - Get user settings
- `POST /<userId>/theme` - Update theme mode

### Command API (`/api/command`)
- `POST /execute` - Execute server command
- `GET /status/<commandId>` - Get command status

### System
- `GET /keepAlive` - Health check endpoint
- `GET /info` - Server version info

## Authentication

Requests must include headers:
- `x-user-id`: User ID
- `x-signature-hash`: Request signature hash

Special endpoints:
- `/event/*` - GCP event authentication (JWT)
- `/backend/*` - Backend key authentication

## Deployment

### Prerequisites
1. Google Cloud project with Artifact Registry
2. Cloud Run API enabled
3. Docker installed

### Deploy Script

```bash
./script_deploy.sh
```

This will:
1. Copy models directory
2. Build Docker image
3. Push to Artifact Registry
4. Deploy to Cloud Run

### Manual Deployment

```bash
# Build
docker build --platform linux/amd64 -t APPNAME-server .

# Tag
docker tag APPNAME-server us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/APPNAME-server

# Push
docker push us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/APPNAME-server

# Deploy
gcloud run deploy APPNAME-server \
  --image us-central1-docker.pkg.dev/PROJECT_ID/REGISTRY/APPNAME-server \
  --region us-central1 \
  --memory 1Gi
```

## Configuration

Update placeholders in:
- `lib/main.dart`: FIREBASE_PROJECT_ID in bucket name
- `lib/util/request_authenticator.dart`: _backendKey
- `script_deploy.sh`: PROJECT_ID, REGION, etc.

## Adding New Endpoints

1. Create API class in `lib/api/`:
```dart
class MyAPI implements Routing {
  @override
  String get prefix => "/api/my";

  @override
  Router get router => Router()
    ..get("/hello", _hello);

  Future<Response> _hello(Request request) async {
    return Response.ok('{"message": "Hello"}');
  }
}
```

2. Register in `main.dart`:
```dart
static late MyAPI apiMy;

Future<void> _startAPIs() async {
  apiMy = MyAPI();
  // ...
}

Router get router => Router()
  ..mount(apiMy.prefix, apiMy.router.call)
  // ...
```

## Adding New Services

1. Create service in `lib/service/my_service.dart`
2. Initialize in `main.dart` `_startServices()`
3. Access via `APPNAMEServer.svcMy`
