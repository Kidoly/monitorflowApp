import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;

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

  List<ChartData> createChartData(List<dynamic> disks) {
    return disks.map<ChartData>((disk) {
      final usedSpace = disk['total_space'] - disk['available_space'];
      final usedSpacePercentage = (usedSpace / disk['total_space']) * 100;
      final color = usedSpacePercentage >= 70 ? Colors.red : Colors.green;
      return ChartData(
        disk['total_space'],
        usedSpacePercentage.round(),
        '${usedSpacePercentage.toStringAsFixed(2)}%',
        color,
      );
    }).toList();
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final details = snapshot.data!;
            final base64Image = details[
                'monitor']; // Assuming 'monitor' is the key for the base64 string
            final usedMemoryInGB =
                (details['used_memory'] / (1024 * 1024 * 1024))
                    .toStringAsFixed(2);
            final totalMemoryInGB =
                (details['total_memory'] / (1024 * 1024 * 1024))
                    .toStringAsFixed(2);

            // Parse the disks JSON string into a List<dynamic>
            final disksJson = details['disks'];
            final disks = jsonDecode(disksJson) as List<dynamic>;

            int totalTotalSpace = 0;
            int totalAvailableSpace = 0;

            for (final disk in disks) {
              totalTotalSpace += disk['total_space'] as int;
              totalAvailableSpace += disk['available_space'] as int;
            }
            final usedSpace = totalTotalSpace - totalAvailableSpace;
            final averageDiskUsage = usedSpace / totalTotalSpace;

            final chartData = createChartData(disks);

            return GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 2 : 1,
              childAspectRatio: 2,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Last update: ${details['date']}'),
                                Text('Start time: ${details['start_time']}'),
                                Text('Cpu usage: ${details['cpu_usage']}%'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final containerShortestSide =
                                          constraints.maxWidth <
                                                  constraints.maxHeight
                                              ? constraints.maxWidth
                                              : constraints.maxHeight;
                                      final needleLength = containerShortestSide *
                                          0.3; // Adjust the multiplier based on your preference

                                      return SfRadialGauge(
                                        axes: <RadialAxis>[
                                          RadialAxis(
                                            minimum: 0,
                                            maximum: (details['total_memory'] /
                                                    (1024 * 1024 * 1024))
                                                .toDouble(),
                                            pointers: <GaugePointer>[
                                              NeedlePointer(
                                                value: (details['used_memory'] /
                                                        (1024 * 1024 * 1024))
                                                    .toDouble(),
                                                enableAnimation: true,
                                                animationDuration: 5000,
                                                knobStyle: const KnobStyle(
                                                    knobRadius: 0),
                                                needleLength: needleLength,
                                                needleEndWidth:
                                                    needleLength / 10,
                                                lengthUnit:
                                                    GaugeSizeUnit.logicalPixel,
                                              ),
                                              RangePointer(
                                                  value:
                                                      (details['used_memory'] /
                                                              (1024 *
                                                                  1024 *
                                                                  1024))
                                                          .toDouble(),
                                                  enableAnimation: true,
                                                  animationDuration: 5000),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        8.0), // Add some space between the gauge and the text
                                Center(
                                  child: Text(
                                    "Memory usage: ${(details['used_memory'] / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB / ${(details['total_memory'] / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final averageDiskUsagePercentage =
                                          averageDiskUsage * 100;

                                      return charts.SfCircularChart(
                                        title: charts.ChartTitle(
                                          text: 'Disks Usage',
                                          textStyle: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        annotations: <charts
                                            .CircularChartAnnotation>[
                                          charts.CircularChartAnnotation(
                                            widget: Container(
                                              child: Text(
                                                '${averageDiskUsagePercentage.toStringAsFixed(0)}%',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          )
                                        ],
                                        series: <charts
                                            .CircularSeries<ChartData, int>>[
                                          charts.RadialBarSeries<ChartData,
                                              int>(
                                            useSeriesColor: true,
                                            trackOpacity: 0.3,
                                            cornerStyle:
                                                charts.CornerStyle.bothCurve,
                                            dataSource:
                                                chartData, // Replace the hardcoded dataSource with chartData
                                            pointRadiusMapper:
                                                (ChartData data, _) =>
                                                    data.text,
                                            pointColorMapper:
                                                (ChartData data, _) =>
                                                    data.color,
                                            xValueMapper:
                                                (ChartData sales, _) => sales.x,
                                            yValueMapper:
                                                (ChartData sales, _) => sales.y,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final containerShortestSide =
                                          constraints.maxWidth <
                                                  constraints.maxHeight
                                              ? constraints.maxWidth
                                              : constraints.maxHeight;
                                      final needleLength = containerShortestSide *
                                          0.3; // Adjust the multiplier based on your preference

                                      return SfRadialGauge(
                                        axes: <RadialAxis>[
                                          RadialAxis(
                                            minimum: 0,
                                            maximum: 100,
                                            pointers: <GaugePointer>[
                                              NeedlePointer(
                                                value: (details['cpu_usage'])
                                                    .toDouble(),
                                                enableAnimation: true,
                                                animationDuration: 5000,
                                                knobStyle: const KnobStyle(
                                                    knobRadius: 0),
                                                needleLength: needleLength,
                                                needleEndWidth:
                                                    needleLength / 10,
                                                lengthUnit:
                                                    GaugeSizeUnit.logicalPixel,
                                              ),
                                              RangePointer(
                                                  value: (details['cpu_usage'])
                                                      .toDouble(),
                                                  enableAnimation: true,
                                                  animationDuration: 5000),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                    height:
                                        8.0), // Add some space between the gauge and the text
                                Center(
                                  child: Text(
                                    "CPU usage: ${(details['cpu_usage']).round()}%",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 2,
                                child: FutureBuilder<ImageProvider>(
                                  future: decodeBase64Image(base64Image),
                                  builder: (context, imageSnapshot) {
                                    if (imageSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (imageSnapshot.hasError) {
                                      return Text(
                                        'Error displaying image: ${imageSnapshot.error}',
                                        style:
                                            const TextStyle(color: Colors.red),
                                      );
                                    } else {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ZoomedImagePage(
                                                imageProvider:
                                                    imageSnapshot.data!,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image(
                                          image: imageSnapshot.data!,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class ZoomedImagePage extends StatelessWidget {
  final ImageProvider imageProvider;

  const ZoomedImagePage({Key? key, required this.imageProvider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.1,
          maxScale: 4.0,
          child: Image(
            image: imageProvider,
          ),
        ),
      ),
    );
  }
}

class ChartData {
  final int x;
  final int y;
  final String text;
  final Color color;

  ChartData(this.x, this.y, this.text, this.color);
}
