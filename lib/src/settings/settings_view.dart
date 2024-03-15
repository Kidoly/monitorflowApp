import 'package:flutter/material.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<ThemeMode>(
              // Read the selected themeMode from the controller
              value: controller.themeMode,
              // Call the updateThemeMode method any time the user selects a theme.
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                )
              ],
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Endpoint'),
              controller: controller.endpointController,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'API Key'),
              controller: controller.apiKeyController,
            ),
            ElevatedButton(
              onPressed: () {
                // Save the API key and endpoint when the button is pressed
                controller.saveApiKey(controller.apiKeyController.text);
                controller.saveEndpoint(controller.endpointController.text);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsViewStateful extends StatefulWidget {
  const SettingsViewStateful({super.key, required this.controller});

  final SettingsController controller;

  @override
  _SettingsViewStatefulState createState() => _SettingsViewStatefulState();
}

class _SettingsViewStatefulState extends State<SettingsViewStateful> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    _controller.apiKeyController.text = await _controller.getApiKey();
    _controller.endpointController.text = await _controller.getEndpoint();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsView(controller: _controller);
  }
}
