import 'package:flutter/material.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  String _endpoint = 'https://albanmary.com/api/api_call.php';
  String _apiKey = 'your_secret_api_key_here';

  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
  }
  // Add methods to get and update endpoint and API key
  String get endpoint => _endpoint;
  String get apiKey => _apiKey;

  Future<void> updateEndpoint(String newEndpoint) async {
    _endpoint = newEndpoint;
    // Persist the changes to a local database or the internet using the SettingService.
  }

  Future<void> updateApiKey(String newApiKey) async {
    _apiKey = newApiKey;
    // Persist the changes to a local database or the internet using the SettingService.
  }
}
