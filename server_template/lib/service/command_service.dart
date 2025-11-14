import 'package:APPNAME_models/APPNAME_models.dart';
import 'package:fast_log/fast_log.dart';
import 'package:fire_crud/fire_crud.dart';
import 'package:uuid/uuid.dart';

/// Service for managing server commands
class CommandService {
  final _uuid = const Uuid();

  CommandService() {
    verbose("CommandService initialized");
  }

  /// Execute a server command
  Future<String> executeCommand({
    required String userId,
    required String commandType,
    required Map<String, dynamic> params,
  }) async {
    try {
      final commandId = _uuid.v4();

      final command = ServerCommand(user: userId);

      await ServerCommand.crud.set(commandId, command);

      verbose("Command $commandId created for user $userId");

      // Process command asynchronously
      _processCommand(commandId, userId, commandType, params);

      return commandId;
    } catch (e) {
      error("Failed to execute command: $e");
      rethrow;
    }
  }

  /// Process a command (runs in background)
  Future<void> _processCommand(
    String commandId,
    String userId,
    String commandType,
    Map<String, dynamic> params,
  ) async {
    try {
      verbose("Processing command $commandId of type $commandType");

      final command = await ServerCommand.crud.get(commandId);
      if (command == null) {
        error("Command $commandId not found");
        return;
      }

      // Simulate command processing
      await Future.delayed(const Duration(seconds: 2));

      // Create success response
      final response = ResponseOK(user: userId);

      await ServerResponse.crud.set(
        commandId,
        response,
        parent: command,
      );

      verbose("Command $commandId completed successfully");
    } catch (e) {
      error("Failed to process command $commandId: $e");

      // Create error response
      try {
        final command = await ServerCommand.crud.get(commandId);
        if (command != null) {
          final response = ResponseError(
            user: userId,
            message: e.toString(),
          );

          await ServerResponse.crud.set(
            commandId,
            response,
            parent: command,
          );
        }
      } catch (responseError) {
        error("Failed to create error response: $responseError");
      }
    }
  }

  /// Get command status
  Future<Map<String, dynamic>?> getCommandStatus(String commandId) async {
    try {
      final command = await ServerCommand.crud.get(commandId);
      if (command == null) return null;

      final response = await ServerResponse.crud.get(
        commandId,
        parent: command,
      );

      if (response == null) {
        return {
          'commandId': commandId,
          'status': 'pending',
        };
      }

      if (response is ResponseOK) {
        return {
          'commandId': commandId,
          'status': 'completed',
          'success': true,
        };
      } else if (response is ResponseError) {
        return {
          'commandId': commandId,
          'status': 'error',
          'success': false,
          'error': response.message,
        };
      }

      return {
        'commandId': commandId,
        'status': 'unknown',
      };
    } catch (e) {
      error("Failed to get command status: $e");
      return null;
    }
  }

  /// Delete a command
  Future<void> deleteCommand(String commandId) async {
    try {
      await ServerCommand.crud.delete(commandId);
      verbose("Deleted command $commandId");
    } catch (e) {
      error("Failed to delete command $commandId: $e");
      rethrow;
    }
  }
}
