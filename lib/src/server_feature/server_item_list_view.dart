import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:monitorflow/src/settings/settings_service.dart';

import '../settings/settings_view.dart';
import 'server_item.dart';

class ServerItemListView extends StatelessWidget {
  const ServerItemListView({Key? key});

  static const routeName = '/';

  Future<List<ServerItem>> fetchServerItems() async {
    final settingsService = SettingsService();
    final response = await http.get(Uri.parse(
        '${settingsService.endpoint}?api_key=${settingsService.apiKey}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((item) => ServerItem.fromJson(item)).toList();
    } else {
      return Future.error('${response.statusCode}: ${response.body}');
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
                final dateFromApi =
                    DateFormat('yyyy-MM-dd HH:mm:ss').parse(item.date);
                final currentDate = DateTime.now();
                final difference =
                    currentDate.difference(dateFromApi).inSeconds;
                final isOverdue = difference > item.intervalTime + 10;

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '${item.hostName} - ${item.systemName}',
                          style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.white),
                        ),
                      ),
                      LinearProgressIndicator(
                        value: double.parse(item.memory),
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
                        arguments: item.hostName);
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
              'Error loading data:\n${snapshot.error}',
              textAlign: TextAlign.center,
            ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
