class ScannedDocument {
  final String id;
  String name;
  final List<String> pageImagePaths;
  String? pdfPath;
  final DateTime createdAt;
  DateTime updatedAt;
  int pageCount;
  String pageSize;
  bool isPasswordProtected;

  ScannedDocument({
    required this.id,
    required this.name,
    required this.pageImagePaths,
    this.pdfPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.pageCount = 0,
    this.pageSize = 'A4',
    this.isPasswordProtected = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'pageImagePaths': pageImagePaths,
      'pdfPath': pdfPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'pageCount': pageCount,
      'pageSize': pageSize,
      'isPasswordProtected': isPasswordProtected,
    };
  }

  factory ScannedDocument.fromJson(Map<String, dynamic> json) {
    return ScannedDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      pageImagePaths: List<String>.from(json['pageImagePaths'] as List),
      pdfPath: json['pdfPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      pageCount: json['pageCount'] as int? ?? 0,
      pageSize: json['pageSize'] as String? ?? 'A4',
      isPasswordProtected: json['isPasswordProtected'] as bool? ?? false,
    );
  }

  ScannedDocument copyWith({
    String? id,
    String? name,
    List<String>? pageImagePaths,
    String? pdfPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? pageCount,
    String? pageSize,
    bool? isPasswordProtected,
  }) {
    return ScannedDocument(
      id: id ?? this.id,
      name: name ?? this.name,
      pageImagePaths: pageImagePaths ?? this.pageImagePaths,
      pdfPath: pdfPath ?? this.pdfPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pageCount: pageCount ?? this.pageCount,
      pageSize: pageSize ?? this.pageSize,
      isPasswordProtected: isPasswordProtected ?? this.isPasswordProtected,
    );
  }
}
