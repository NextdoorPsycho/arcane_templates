import 'dart:convert';

import 'package:APPNAME_server/main.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Command API endpoints for server commands
class CommandAPI implements Routing {
  @override
  String get prefix => "/api/command";

  @override
  Router get router => Router()
    ..post("/execute", _executeCommand)
    ..get("/status/<commandId>", _getCommandStatus);

  /// Execute a server command
  Future<Response> _executeCommand(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);
      final userId = data['userId'] as String?;
      final commandType = data['type'] as String?;

      if (userId == null || commandType == null) {
        return Response.badRequest(
          body: '{"error": "userId and type are required"}',
        );
      }

      final commandId = await APPNAMEServer.svcCommand.executeCommand(
        userId: userId,
        commandType: commandType,
        params: data['params'] as Map<String, dynamic>? ?? {},
      );

      return Response.ok(
        jsonEncode({
          'commandId': commandId,
          'status': 'pending',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: '{"error": "$e"}',
      );
    }
  }

  /// Get command execution status
  Future<Response> _getCommandStatus(
    Request request,
    String commandId,
  ) async {
    try {
      final status = await APPNAMEServer.svcCommand.getCommandStatus(
        commandId,
      );

      if (status == null) {
        return Response.notFound('{"error": "Command not found"}');
      }

      return Response.ok(
        jsonEncode(status),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: '{"error": "$e"}',
      );
    }
  }
}
