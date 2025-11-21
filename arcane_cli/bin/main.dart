import 'package:APPNAME_cli/APPNAME_cli.dart';

/// Entry point for APPNAME CLI application
void main(List<String> arguments) async {
  final runner = APPNAMERunner();
  await runner.run(arguments);
}
