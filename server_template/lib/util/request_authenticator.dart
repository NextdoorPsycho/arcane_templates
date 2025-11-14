import 'dart:io';

import 'package:arcane_admin/arcane_admin.dart';
import 'package:fast_log/fast_log.dart';
import 'package:APPNAME_models/APPNAME_models.dart';
import 'package:precision_stopwatch/precision_stopwatch.dart';
import 'package:shelf/shelf.dart';

// Backend key for server-to-server authentication
// IMPORTANT: Change this to a secure random key in production
const String _backendKey =
    r"""CHANGE_THIS_TO_A_SECURE_RANDOM_KEY_IN_PRODUCTION""";

// Authentication caches
Map<String, DateTime> validAuthentications = {};
Map<String, DateTime> invalidAuthentications = {};
const int timingAttackDelay = 50;

enum AuthResponse { invalid, validated, alreadyValidated }

/// Handles request authentication using signature-based authentication
class RequestAuthenticator {
  int $lastCleanup = 0;

  Future<Response?> authenticateRequest(Request request) async {
    // Public info endpoint
    if (request.url.path == "info") {
      return Response.ok("APPNAME Server v1.0.0");
    }

    // Keep-alive endpoint
    if (request.url.path == "keepAlive") {
      return null;
    }

    // GCP Event endpoints (authenticated via JWT)
    if (request.url.path.startsWith("event")) {
      if (!await ArcaneAdmin.validation.validateGCPRequestJWT(request)) {
        return Response.forbidden("Invalid Request");
      }
      return null;
    }

    // Backend endpoints (authenticated via API key)
    if (request.url.path.startsWith("backend")) {
      if (request.headers["key"] != _backendKey) {
        return Response.forbidden("Invalid Request");
      }
      return null;
    }

    // Signature-based authentication for regular API endpoints
    PrecisionStopwatch p = PrecisionStopwatch.start();
    int d = timingAttackDelay - p.getMilliseconds().ceil();

    Future<Response?> timing(Response? r) async {
      if (d > 0) {
        await Future.delayed(Duration(milliseconds: d));
      } else {
        warn(
          'Unauthenticated request took longer than timing attack delay of ${timingAttackDelay}ms (${p.getMilliseconds()}ms). Consider increasing the delay.',
        );
      }
      return r;
    }

    return switch (await _isAuthenticatedRequest(request)) {
      AuthResponse.invalid => timing(Response.forbidden('Invalid Request')),
      AuthResponse.validated => timing(null),
      AuthResponse.alreadyValidated => null,
    };
  }

  Future<AuthResponse> _isAuthenticatedRequest(Request request) async {
    // Get authentication headers
    dynamic uid = request.headers["x-user-id"];
    dynamic sih = request.headers["x-signature-hash"];

    if (uid is! String || sih is! String) {
      return AuthResponse.invalid;
    }

    // Get client IP for cache key
    final String ip =
        (request.context['shelf.io.connection_info'] as HttpConnectionInfo?)
                ?.remoteAddress
                .address ??
            "?";
    String key = "$uid:$sih@$ip";
    scheduleCleanup();

    // Check invalid auth cache
    if (invalidAuthentications.containsKey(key) &&
        DateTime.timestamp()
                .difference(invalidAuthentications[key]!)
                .inMinutes <
            4) {
      return AuthResponse.invalid;
    }

    // Check valid auth cache
    if (validAuthentications.containsKey(key) &&
        DateTime.timestamp().difference(validAuthentications[key]!).inMinutes <
            4) {
      return AuthResponse.alreadyValidated;
    }

    // Fetch user from Firestore
    User? user = await User.crud.get(uid);
    if (user == null) {
      invalidAuthentications[key] = DateTime.timestamp();
      return AuthResponse.invalid;
    }

    // Get user settings with signatures
    UserSettings? settings = await UserSettings.crud.get(
      uid,
      parent: user,
    );

    if (settings == null) {
      invalidAuthentications[key] = DateTime.timestamp();
      return AuthResponse.invalid;
    }

    // Validate signature hash (if signature system is implemented)
    // This is a placeholder - implement signature validation based on your needs
    validAuthentications[key] = DateTime.timestamp();
    return AuthResponse.validated;
  }

  void scheduleCleanup() {
    if (DateTime.timestamp().millisecondsSinceEpoch - $lastCleanup > 60000 ||
        (validAuthentications.length + invalidAuthentications.length) > 10000) {
      validAuthentications.removeWhere(
        (key, value) => DateTime.timestamp().difference(value).inMinutes > 4,
      );
      invalidAuthentications.removeWhere(
        (key, value) => DateTime.timestamp().difference(value).inMinutes > 4,
      );
      $lastCleanup = DateTime.timestamp().millisecondsSinceEpoch;
    }
  }
}

/// Request extension for easy access to user ID
extension XRequest on Request {
  String? get userId => headers["x-user-id"];
}
