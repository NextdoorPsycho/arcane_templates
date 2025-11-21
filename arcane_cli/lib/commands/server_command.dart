// CONDITIONAL_FILE: This file is only included if server package is enabled during setup
import 'dart:convert';
import 'dart:io';
import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

part 'server_command.g.dart';

/// Server API interaction commands
///
/// Provides commands for calling the APPNAME server REST API.
/// Requires server URL and authentication key to be configured.
@cliSubcommand
class ServerCommand extends _$ServerCommand {
  /// Get server URL from config or environment
  String get serverUrl {
    // Try environment variable first
    final envUrl = Platform.environment['APPNAME_SERVER_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // Try config file
    final configPath = p.join(
      Platform.environment['HOME'] ?? '',
      '.APPNAME',
      'config.yaml',
    );

    if (File(configPath).existsSync()) {
      final content = File(configPath).readAsStringSync();
      // Simple YAML parsing for server_url key
      final regex = RegExp(r'server_url:\s*(.+)');
      final match = regex.firstMatch(content);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }

    // Default to localhost
    return 'http://localhost:8080';
  }

  /// Get API key from config or environment
  String? get apiKey {
    // Try environment variable first
    final envKey = Platform.environment['APPNAME_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      return envKey;
    }

    // Try config file
    final configPath = p.join(
      Platform.environment['HOME'] ?? '',
      '.APPNAME',
      'config.yaml',
    );

    if (File(configPath).existsSync()) {
      final content = File(configPath).readAsStringSync();
      final regex = RegExp(r'api_key:\s*(.+)');
      final match = regex.firstMatch(content);
      if (match != null) {
        return match.group(1)!.trim();
      }
    }

    return null;
  }

  /// Generate request signature for authenticated API calls
  String _generateSignature(String path, String timestamp, String body) {
    final key = apiKey;
    if (key == null) {
      throw Exception('API key not configured');
    }

    final message = '$path$timestamp$body';
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(message));
    return digest.toString();
  }

  /// Make authenticated API request
  Future<http.Response> _apiRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$serverUrl$path');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final bodyStr = body != null ? jsonEncode(body) : '';

    final signature = _generateSignature(path, timestamp, bodyStr);

    final headers = {
      'Content-Type': 'application/json',
      'X-Timestamp': timestamp,
      'X-Signature': signature,
    };

    verbose("$method $url");
    verbose("Headers: $headers");

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(url, headers: headers, body: bodyStr);
      case 'PUT':
        return http.put(url, headers: headers, body: bodyStr);
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  /// Ping the server to check if it's running
  @cliCommand
  Future<void> ping() async {
    info("Pinging server at: $serverUrl");

    try {
      final response = await http.get(Uri.parse('$serverUrl/health')).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        print('\n┌─ Server Status ──────────────────────┐');
        print('│ URL: ${serverUrl.padRight(30)}│');
        print('│ Status: Online'.padRight(41) + '│');
        print('│ Response: ${response.statusCode.toString().padRight(27)}│');
        print('└──────────────────────────────────────┘\n');
        success("Server is online");
      } else {
        warn("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      error("Server is offline or unreachable: $e");
    }
  }

  /// Get server information
  @cliCommand
  Future<void> sinfo() async {
    info("Retrieving server information...");

    try {
      final response = await _apiRequest('GET', '/api/info');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('\n┌─ Server Information ─────────────────┐');
        print('│ URL: $serverUrl');
        print('│ Status: Connected');
        print('├──────────────────────────────────────┤');
        print('│ Response:');
        print('│ ${jsonEncode(data)}');
        print('└──────────────────────────────────────┘\n');
        success("Server information retrieved");
      } else {
        error("Failed to get server info: ${response.statusCode}");
        error("Response: ${response.body}");
      }
    } catch (e, stack) {
      error("Failed to contact server: $e");
      verbose(stack.toString());
    }
  }

  /// Configure server connection
  @cliCommand
  Future<void> configure({
    /// Server URL (e.g., https://api.example.com)
    String? url,

    /// API key for authentication
    String? key,
  }) async {
    info("Configuring server connection...");

    final configDir = p.join(Platform.environment['HOME'] ?? '', '.APPNAME');
    final configPath = p.join(configDir, 'config.yaml');

    // Create config directory if needed
    await Directory(configDir).create(recursive: true);

    // Read existing config or create new
    String config;
    if (File(configPath).existsSync()) {
      config = File(configPath).readAsStringSync();
    } else {
      config = '# APPNAME Configuration\n\n';
    }

    // Update or append server_url
    if (url != null) {
      if (config.contains('server_url:')) {
        config = config.replaceAll(
          RegExp(r'server_url:.*'),
          'server_url: $url',
        );
      } else {
        config += 'server_url: $url\n';
      }
      success("Server URL configured: $url");
    }

    // Update or append api_key
    if (key != null) {
      if (config.contains('api_key:')) {
        config = config.replaceAll(
          RegExp(r'api_key:.*'),
          'api_key: $key',
        );
      } else {
        config += 'api_key: $key\n';
      }
      success("API key configured");
    }

    await File(configPath).writeAsString(config);
    success("Configuration saved to: $configPath");
  }

  /// Test authenticated API call
  @cliCommand
  Future<void> test() async {
    info("Testing authenticated API call...");

    if (apiKey == null) {
      error("API key not configured. Run: APPNAME server configure --key YOUR_KEY");
      return;
    }

    try {
      final response = await _apiRequest('GET', '/api/test');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('\n┌─ API Test Result ────────────────────┐');
        print('│ Status: Success');
        print('│ Response: ${jsonEncode(data)}');
        print('└──────────────────────────────────────┘\n');
        success("Authenticated API call successful");
      } else {
        error("API call failed: ${response.statusCode}");
        error("Response: ${response.body}");
      }
    } catch (e, stack) {
      error("Failed to test API: $e");
      verbose(stack.toString());
    }
  }
}
