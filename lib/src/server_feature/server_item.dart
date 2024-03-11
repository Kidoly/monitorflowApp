class ServerItem {
  final String hostName;
  final String memory;
  final String systemName;
  final String date;
  final int intervalTime;

  const ServerItem({
    required this.hostName,
    required this.memory,
    required this.systemName,
    required this.date,
    required this.intervalTime,
  });

  factory ServerItem.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'host_name': String hostName,
        'memory': String memory,
        'system_name': String systemName,
        'date': String date,
        'interval_time': int intervalTime,
      } =>
        ServerItem(
          hostName: hostName,
          memory: memory,
          systemName: systemName,
          date: date,
          intervalTime: intervalTime,
        ),
      _ => throw const FormatException('Failed to load servers.'),
    };
  }
}
