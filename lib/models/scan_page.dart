import 'dart:typed_data';

class ScanPage {
  final String id;
  final String imagePath;
  final DateTime createdAt;
  Uint8List? processedImageBytes;
  String activeFilter;
  double brightness;
  double contrast;
  double rotation;

  ScanPage({
    required this.id,
    required this.imagePath,
    DateTime? createdAt,
    this.processedImageBytes,
    this.activeFilter = 'Original',
    this.brightness = 0.0,
    this.contrast = 0.0,
    this.rotation = 0.0,
  }) : createdAt = createdAt ?? DateTime.now();

  ScanPage copyWith({
    String? id,
    String? imagePath,
    DateTime? createdAt,
    Uint8List? processedImageBytes,
    String? activeFilter,
    double? brightness,
    double? contrast,
    double? rotation,
  }) {
    return ScanPage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
      activeFilter: activeFilter ?? this.activeFilter,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'activeFilter': activeFilter,
      'brightness': brightness,
      'contrast': contrast,
      'rotation': rotation,
    };
  }

  factory ScanPage.fromJson(Map<String, dynamic> json) {
    return ScanPage(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      activeFilter: json['activeFilter'] as String? ?? 'Original',
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 0.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
