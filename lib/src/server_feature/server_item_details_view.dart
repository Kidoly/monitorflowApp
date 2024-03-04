import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerItemDetailsView extends StatelessWidget {
  const ServerItemDetailsView({super.key, required this.serverName});

  final String serverName;

  Future<Map<String, dynamic>> fetchServerDetails() async {
    final response = await http.get(Uri.parse(
        'https://albanmary.com/api/api_call.php?api_key=your_secret_api_key_here&host_name=$serverName'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load server details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details for $serverName'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchServerDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final details = snapshot.data!;
            // Display details from the map (e.g., CPU usage, uptime, etc.)
            return ListView(
              children: [
                ListTile(
                  title: Text('CPU Usage: ${details['cpu_usage']}%'),
                ),
                // Add more ListTile widgets for other details based on the API response structure
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading details'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
