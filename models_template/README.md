# APPNAME Models

Shared data models package for APPNAME.

## Structure

- **User Models**: User account and settings with theme mode support
- **Server Models**: Command/Response patterns for server communication
- **Authentication**: Server signature system for secure requests

## Usage

### Register Models

```dart
import 'package:APPNAME_models/APPNAME_models.dart';

void main() {
  registerCrud();
  // Your app initialization
}
```

### Generate Code

Run code generation after modifying models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use the script:

```bash
flutter pub run script build_runner
```

## Adding New Models

1. Add your model class with `@model` annotation
2. Implement `ModelCrud` mixin
3. Define `childModels` if needed
4. Register in `registerCrud()`
5. Run build_runner

Example:

```dart
@model
class MyModel with ModelCrud {
  final String name;

  MyModel({required this.name});

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}
```

Then add to `registerCrud()`:

```dart
FireModel<MyModel>.artifact("mymodel"),
```
