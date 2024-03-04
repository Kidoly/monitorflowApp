class ServerItem {
  final String hostName;
  final String memory;
  final String systemName;

  const ServerItem({
    required this.hostName,
    required this.memory,
    required this.systemName,
  });

  factory ServerItem.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'host_name': String hostName,
        'memory': String memory,
        'system_name': String systemName,
      } =>
        ServerItem(
          hostName: hostName,
          memory: memory,
          systemName: systemName,
        ),
      _ => throw const FormatException('Failed to load servers.'),
    };
  }
}
