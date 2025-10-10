class FeedingSchedule {
  final String id;
  final String aquariumId;
  final String time; // Format: "HH:mm" (24-hour)
  final int cycles; // maps to backend 'cycle'
  final String foodType; // maps to backend 'food'
  final bool isEnabled; // maps to backend 'switch' // maps to backend 'daily'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedingSchedule({
    required this.id,
    required this.aquariumId,
    required this.time,
    required this.cycles,
    required this.foodType,
    required this.isEnabled,
    required this.createdAt,
    this.updatedAt,
  });

  factory FeedingSchedule.fromJson(Map<String, dynamic> json) {
    return FeedingSchedule(
      // Flask backend uses 'time' as unique key per aquarium; reflect it as id
      id: (json['id'] ?? json['time'] ?? '').toString(),
      aquariumId: json['aquarium_id']?.toString() ?? '',
      time: json['time']?.toString() ?? '00:00',
      cycles:
          (json['cycles'] ?? json['cycle'] ?? 1) is int
              ? (json['cycles'] ?? json['cycle']) as int
              : int.tryParse(
                    (json['cycles'] ?? json['cycle'] ?? '1').toString(),
                  ) ??
                  1,
      foodType: (json['food_type'] ?? json['food'] ?? 'Default').toString(),
      isEnabled: (json['is_enabled'] ?? json['switch'] ?? false) == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Prefer Flask backend field names
      'id': id,
      'aquarium_id': aquariumId,
      'time': time,
      'cycle': cycles,
      'food': foodType,
      'switch': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  FeedingSchedule copyWith({
    String? id,
    String? aquariumId,
    String? time,
    int? cycles,
    String? foodType,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeedingSchedule(
      id: id ?? this.id,
      aquariumId: aquariumId ?? this.aquariumId,
      time: time ?? this.time,
      cycles: cycles ?? this.cycles,
      foodType: foodType ?? this.foodType,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedingSchedule && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FeedingSchedule(id: $id, aquariumId: $aquariumId, time: $time, cycles: $cycles, foodType: $foodType, isEnabled: $isEnabled)';
  }
}

class AutoFeederStatus {
  final String aquariumId;
  final bool isEnabled;
  final DateTime lastUpdated;

  const AutoFeederStatus({
    required this.aquariumId,
    required this.isEnabled,
    required this.lastUpdated,
  });

  factory AutoFeederStatus.fromJson(Map<String, dynamic> json) {
    return AutoFeederStatus(
      aquariumId: json['aquarium_id']?.toString() ?? '',
      isEnabled: json['enabled'] == true,
      lastUpdated:
          DateTime.tryParse(json['last_updated']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aquarium_id': aquariumId,
      'enabled': isEnabled,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  AutoFeederStatus copyWith({
    String? aquariumId,
    bool? isEnabled,
    DateTime? lastUpdated,
  }) {
    return AutoFeederStatus(
      aquariumId: aquariumId ?? this.aquariumId,
      isEnabled: isEnabled ?? this.isEnabled,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
