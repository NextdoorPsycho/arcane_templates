library APPNAME_models;

import 'dart:convert';
import 'dart:math';

import 'package:artifact/artifact.dart';
import 'package:crypto/crypto.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:APPNAME_models/gen/artifacts.gen.dart';

export 'package:APPNAME_models/gen/artifacts.gen.dart';
export 'package:APPNAME_models/gen/crud.gen.dart';

void registerCrud() => $crud
  ..setupArtifact($artifactFromMap, $artifactToMap, $constructArtifact)
  ..registerModels([
    FireModel<User>.artifact("user"),
    FireModel<ServerCommand>.artifact("command"),
  ]);

const model = Artifact(
  generateSchema: false,
  reflection: false,
  compression: true,
);

const server = Artifact(
  generateSchema: false,
  reflection: false,
  compression: true,
);

const reflect = Artifact(
  generateSchema: false,
  reflection: true,
  compression: true,
);

// ============================================================================
// User Model
// ============================================================================

@model
class User with ModelCrud {
  final String name;
  final String email;
  final String? profileHash;

  User({
    required this.name,
    required this.email,
    this.profileHash,
  });

  @override
  List<FireModel<ModelCrud>> get childModels => [
        FireModel<UserSettings>.artifact(
          "data",
          exclusiveDocumentId: "settings",
        ),
      ];
}

@model
class UserSettings with ModelCrud {
  final ThemeMode themeMode;

  UserSettings({this.themeMode = ThemeMode.system});

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}

@model
enum ThemeMode {
  light,
  dark,
  system,
}

// ============================================================================
// Server Command & Response Models
// ============================================================================

@server
class ServerCommand with ModelCrud {
  final String user;

  ServerCommand({required this.user});

  @override
  List<FireModel<ModelCrud>> get childModels => [
        FireModel<ServerResponse>.artifact(
          "response",
          exclusiveDocumentId: "response",
        ),
      ];
}

@server
class ServerResponse with ModelCrud {
  final String user;

  ServerResponse({required this.user});

  @override
  List<FireModel<ModelCrud>> get childModels => [];
}

@server
class ResponseOK extends ServerResponse {
  ResponseOK({required super.user});
}

@server
class ResponseError extends ServerResponse {
  final String message;

  ResponseError({required super.user, required this.message});
}

// ============================================================================
// Server Signature (for authentication)
// ============================================================================

@model
class APPNAMEServerSignature {
  final String signature;
  final String session;
  final int time;

  APPNAMEServerSignature({
    required this.signature,
    required this.session,
    required this.time,
  });

  static String? _sessionId;
  static String get sessionId {
    if (_sessionId == null) {
      Random r = Random();
      _sessionId = base64Encode(
        List.generate(128, (i) => r.nextInt(256)).toList(),
      );
    }

    return _sessionId!;
  }

  String get hash =>
      sha256.convert(utf8.encode("$signature:$session@$time")).toString();

  static String get randomSignature {
    Random random = Random();
    return base64Encode(
      List.generate(128, (i) => random.nextInt(256)).toList(),
    );
  }

  static APPNAMEServerSignature newSignature() => APPNAMEServerSignature(
        signature: randomSignature,
        session: sessionId,
        time: DateTime.timestamp().millisecondsSinceEpoch,
      );
}
