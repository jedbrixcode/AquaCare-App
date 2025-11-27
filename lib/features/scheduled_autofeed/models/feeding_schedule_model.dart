// Helper function to safely parse DateTime from various formats
DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  
  try {
    // If it's already a DateTime, return it
    if (value is DateTime) return value;
    
    // If it's a number (timestamp in milliseconds or seconds)
    if (value is num) {
      final timestamp = value.toInt();
      // Check if it's in seconds (less than year 2000 in milliseconds)
      if (timestamp < 946684800000) {
        // Likely seconds, convert to milliseconds
        return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      } else {
        // Likely milliseconds
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }
    
    // Try parsing as string
    final str = value.toString().trim();
    if (str.isEmpty) return null;
    
    // Try ISO8601 format first
    final parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;
    
    // If parsing fails, return null (no exception thrown)
    return null;
  } catch (e) {
    // Catch any unexpected errors and return null
    return null;
  }
}

class FeedingSchedule {
  final String id;
  final String aquariumId;
  final String time; // Format: "HH:mm" (24-hour)
  final int cycles; // maps to backend 'cycle'
  final String foodType; // maps to backend 'food'
  final bool isEnabled; // maps to backend 'switch'
  final bool daily; // maps to backend 'daily'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeedingSchedule({
    required this.id,
    required this.aquariumId,
    required this.time,
    required this.cycles,
    required this.foodType,
    required this.isEnabled,
    this.daily = true,
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
      foodType: (json['food_type'] ?? json['food']).toString(),
      isEnabled: (json['is_enabled'] ?? json['switch'] ?? false) == true,
      daily: (json['daily'] ?? true) == true,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
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
      'daily': daily,
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
    bool? daily,
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
      daily: daily ?? this.daily,
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
      lastUpdated: _parseDateTime(json['last_updated']) ?? DateTime.now(),
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
