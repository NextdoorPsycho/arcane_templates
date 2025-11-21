import 'dart:io';
import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

part 'config_command.g.dart';

/// Configuration management commands
///
/// Manages application configuration stored in a local YAML file.
/// Configuration is stored in ~/.APPNAME/config.yaml by default.
@cliSubcommand
class ConfigCommand extends _$ConfigCommand {
  /// Get the configuration directory path
  String get configDir {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
    if (home == null) {
      throw Exception('Could not determine home directory');
    }
    return p.join(home, '.APPNAME');
  }

  /// Get the configuration file path
  String get configPath => p.join(configDir, 'config.yaml');

  /// Initialize configuration file with default values
  @cliCommand
  Future<void> init({
    /// Overwrite existing configuration
    bool force = false,
  }) async {
    info("Initializing configuration...");

    final configFile = File(configPath);

    if (configFile.existsSync() && !force) {
      warn("Configuration already exists at: $configPath");
      info("Use --force to overwrite");
      return;
    }

    // Create config directory if it doesn't exist
    await Directory(configDir).create(recursive: true);

    // Write default configuration
    final defaultConfig = '''
# APPNAME Configuration File
# Generated: ${DateTime.now().toIso8601String()}

# General Settings
app_name: APPNAME
version: 1.0.0

# Add your custom configuration here
''';

    await configFile.writeAsString(defaultConfig);
    success("Configuration initialized at: $configPath");
  }

  /// Get a configuration value by key
  @cliCommand
  Future<void> get(
    /// Configuration key (e.g., app_name, version)
    String key,
  ) async {
    info("Reading configuration key: $key");

    final configFile = File(configPath);

    if (!configFile.existsSync()) {
      error("Configuration not found. Run 'APPNAME config init' first.");
      return;
    }

    final content = await configFile.readAsString();
    final yaml = loadYaml(content);

    if (yaml is! Map) {
      error("Invalid configuration format");
      return;
    }

    final value = yaml[key];

    if (value == null) {
      warn("Key '$key' not found in configuration");
      return;
    }

    print('$key: $value');
    success("Retrieved configuration value");
  }

  /// Set a configuration value
  @cliCommand
  Future<void> set(
    /// Configuration key
    String key,

    /// Configuration value
    String value,
  ) async {
    info("Setting configuration: $key = $value");

    final configFile = File(configPath);

    if (!configFile.existsSync()) {
      error("Configuration not found. Run 'APPNAME config init' first.");
      return;
    }

    // Read existing config
    final content = await configFile.readAsString();
    final lines = content.split('\n');

    // Find and update the key, or append it
    bool found = false;
    final updatedLines = <String>[];

    for (final line in lines) {
      if (line.trim().startsWith('$key:')) {
        updatedLines.add('$key: $value');
        found = true;
      } else {
        updatedLines.add(line);
      }
    }

    if (!found) {
      updatedLines.add('$key: $value');
    }

    await configFile.writeAsString(updatedLines.join('\n'));
    success("Configuration updated: $key = $value");
  }

  /// List all configuration values
  @cliCommand
  Future<void> list() async {
    info("Listing configuration...");

    final configFile = File(configPath);

    if (!configFile.existsSync()) {
      error("Configuration not found. Run 'APPNAME config init' first.");
      return;
    }

    final content = await configFile.readAsString();
    final yaml = loadYaml(content);

    if (yaml is! Map) {
      error("Invalid configuration format");
      return;
    }

    print('\nConfiguration ($configPath):');
    print('─' * 50);

    yaml.forEach((key, value) {
      print('$key: $value');
    });

    print('─' * 50);
    success("Listed ${yaml.length} configuration value(s)");
  }

  /// Show configuration file path
  @cliCommand
  Future<void> path() async {
    print('Configuration path: $configPath');
    final exists = File(configPath).existsSync();
    print('Exists: ${exists ? 'Yes' : 'No'}');

    if (!exists) {
      info("Run 'APPNAME config init' to create configuration");
    }
  }
}
