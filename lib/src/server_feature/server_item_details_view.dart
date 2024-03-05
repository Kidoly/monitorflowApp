import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServerItemDetailsView extends StatelessWidget {
  const ServerItemDetailsView({Key? key, required this.serverName})
      : super(key: key);

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

  Future<ImageProvider> decodeBase64Image(String base64String) async {
    // Remove the quotes and \/ from the base64 string
    final cleanedString =
        base64String.replaceAll('"', '').replaceAll(r'\/', '/');
    final bytes = base64Decode(cleanedString);
    return MemoryImage(bytes);
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final details = snapshot.data!;
            final base64Image = details[
                'monitor']; // Assuming 'monitor' is the key for the base64 string
            return ListView(
              children: [
                ListTile(
                  title: Text('Memory: ${details['memory']}'),
                ),
                FutureBuilder<ImageProvider>(
                  future: decodeBase64Image(base64Image),
                  builder: (context, imageSnapshot) {
                    if (imageSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (imageSnapshot.hasError) {
                      return Text(
                        'Error displaying image: ${imageSnapshot.error}',
                        style: TextStyle(color: Colors.red),
                      );
                    } else {
                      return Image(
                        image: imageSnapshot.data!,
                      );
                    }
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
