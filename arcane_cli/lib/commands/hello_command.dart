import 'package:cli_annotations/cli_annotations.dart';
import 'package:fast_log/fast_log.dart';

part 'hello_command.g.dart';

/// Hello world command - demonstrates basic CLI structure
@cliSubcommand
class HelloCommand extends _$HelloCommand {
  /// Say hello with optional customization
  ///
  /// This is a simple command that demonstrates:
  /// - Required and optional parameters
  /// - Named flags
  /// - Type-safe argument parsing
  /// - Logging integration
  @cliCommand
  Future<void> greet(
    /// The name to greet
    String name, {
    /// Number of times to repeat the greeting
    int times = 1,

    /// Add enthusiasm with exclamation marks
    bool enthusiastic = false,
  }) async {
    info("Executing greet command for: $name");

    final punctuation = enthusiastic ? '!' : '.';
    final greeting = 'Hello, $name$punctuation';

    for (int i = 0; i < times; i++) {
      print(greeting);
    }

    success("Greeted $name $times time${times == 1 ? '' : 's'}");
  }

  /// Display version information
  @cliCommand
  Future<void> version() async {
    print('APPNAME CLI v1.0.0');
    print('Built with Arcane Templates');
  }
}
