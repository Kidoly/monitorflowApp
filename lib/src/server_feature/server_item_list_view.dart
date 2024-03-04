import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../settings/settings_view.dart';
import 'server_item.dart';
import 'server_item_details_view.dart';

class ServerItemListView extends StatelessWidget {
  const ServerItemListView({Key? key});

  static const routeName = '/';

  Future<List<ServerItem>> fetchServerItems() async {
    final response = await http.get(Uri.parse(
        'https://albanmary.com/api/api_call.php?api_key=your_secret_api_key_here'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => ServerItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load server items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MonitorFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<ServerItem>>(
        future: fetchServerItems(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              restorationId: 'ServerItemListView',
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('${item.hostName} - ${item.systemName}'),
                      ),
                      LinearProgressIndicator(
                        value: double.parse(item
                            .memory), // Assuming item.memory is a double between 0 and 1
                        backgroundColor: Colors.grey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                        borderRadius: BorderRadius.circular(10.0),
                        minHeight: 8,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.restorablePushNamed(context, '/serverDetails',
                        arguments: item.hostName); // Updated route name
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}