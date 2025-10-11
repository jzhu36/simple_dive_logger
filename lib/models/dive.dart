class Dive {
  final int? id;
  final String date;
  final String time;
  final String? country;
  final String? diveSiteName;
  final double? latitude;
  final double? longitude;
  final double maxDepth;
  final int duration;
  final double? waterTemperature;
  final String? visibility;
  final String? notes;
  final String status;
  final String createdAt;
  final String updatedAt;

  const Dive({
    this.id,
    required this.date,
    required this.time,
    this.country,
    this.diveSiteName,
    this.latitude,
    this.longitude,
    required this.maxDepth,
    required this.duration,
    this.waterTemperature,
    this.visibility,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy of this Dive with updated fields
  Dive copyWith({
    int? id,
    String? date,
    String? time,
    String? country,
    String? diveSiteName,
    double? latitude,
    double? longitude,
    double? maxDepth,
    int? duration,
    double? waterTemperature,
    String? visibility,
    String? notes,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Dive(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      country: country ?? this.country,
      diveSiteName: diveSiteName ?? this.diveSiteName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxDepth: maxDepth ?? this.maxDepth,
      duration: duration ?? this.duration,
      waterTemperature: waterTemperature ?? this.waterTemperature,
      visibility: visibility ?? this.visibility,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert Dive to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'country': country,
      'dive_site_name': diveSiteName,
      'latitude': latitude,
      'longitude': longitude,
      'max_depth': maxDepth,
      'duration': duration,
      'water_temperature': waterTemperature,
      'visibility': visibility,
      'notes': notes,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Create Dive from SQLite Map
  factory Dive.fromMap(Map<String, dynamic> map) {
    return Dive(
      id: map['id'] as int?,
      date: map['date'] as String,
      time: map['time'] as String,
      country: map['country'] as String?,
      diveSiteName: map['dive_site_name'] as String?,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      maxDepth: map['max_depth'] as double,
      duration: map['duration'] as int,
      waterTemperature: map['water_temperature'] as double?,
      visibility: map['visibility'] as String?,
      notes: map['notes'] as String?,
      status: map['status'] as String? ?? 'completed',
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  /// Get formatted location string for display
  String getLocationDisplay() {
    if (diveSiteName != null && country != null) {
      return '$diveSiteName, $country';
    } else if (diveSiteName != null) {
      return diveSiteName!;
    } else if (country != null) {
      return country!;
    } else if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(4)}, ${longitude!.toStringAsFixed(4)}';
    } else {
      return 'Location not specified';
    }
  }

  /// Validate dive data
  String? validate() {
    if (maxDepth < 0 || maxDepth > 300) {
      return 'Max depth must be between 0 and 300 meters';
    }
    if (duration < 0 || duration > 999) {
      return 'Duration must be between 0 and 999 minutes';
    }
    if (waterTemperature != null &&
        (waterTemperature! < -2 || waterTemperature! > 40)) {
      return 'Water temperature must be between -2 and 40°C';
    }
    if (latitude != null && (latitude! < -90 || latitude! > 90)) {
      return 'Latitude must be between -90 and 90';
    }
    if (longitude != null && (longitude! < -180 || longitude! > 180)) {
      return 'Longitude must be between -180 and 180';
    }
    if (status != 'in_progress' && status != 'completed') {
      return 'Status must be either "in_progress" or "completed"';
    }
    return null;
  }

  @override
  String toString() {
    return 'Dive(id: $id, date: $date, time: $time, location: ${getLocationDisplay()}, '
        'maxDepth: $maxDepth, duration: $duration, status: $status)';
  }
}
