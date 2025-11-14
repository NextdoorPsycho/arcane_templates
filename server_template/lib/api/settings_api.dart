import 'dart:convert';

import 'package:APPNAME_models/APPNAME_models.dart';
import 'package:APPNAME_server/main.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Settings API endpoints for user preferences
class SettingsAPI implements Routing {
  @override
  String get prefix => "/api/settings";

  @override
  Router get router => Router()
    ..get("/<userId>", _getSettings)
    ..post("/<userId>/theme", _updateTheme);

  /// Get user settings
  Future<Response> _getSettings(Request request, String userId) async {
    try {
      final settings = await APPNAMEServer.svcUser.getUserSettings(userId);

      if (settings == null) {
        return Response.notFound('{"error": "Settings not found"}');
      }

      return Response.ok(
        jsonEncode({
          'themeMode': settings.themeMode.name,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: '{"error": "$e"}',
      );
    }
  }

  /// Update theme mode
  Future<Response> _updateTheme(Request request, String userId) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final themeModeStr = data['themeMode'] as String?;

      if (themeModeStr == null) {
        return Response.badRequest(
          body: '{"error": "themeMode is required"}',
        );
      }

      final themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeModeStr,
        orElse: () => ThemeMode.system,
      );

      await APPNAMEServer.svcUser.updateTheme(userId, themeMode);

      return Response.ok('{"success": true}');
    } catch (e) {
      return Response.internalServerError(
        body: '{"error": "$e"}',
      );
    }
  }
}
