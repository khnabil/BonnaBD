class Station {
  final int id;
  final String name;
  final String river;
  final double currentLevel;
  final double dangerLevel;
  final String lastUpdated;

  Station({
    required this.id,
    required this.name,
    required this.river,
    required this.currentLevel,
    required this.dangerLevel,
    required this.lastUpdated,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? 0,
      name: json['station_name'] ?? "Unknown",
      river: json['river_name'] ?? "Unknown River",
      currentLevel: (json['water_level'] ?? 0.0).toDouble(),
      dangerLevel: (json['danger_level'] ?? 0.0).toDouble(),
      lastUpdated: json['last_updated'] ?? DateTime.now().toString(),
    );
  }
}