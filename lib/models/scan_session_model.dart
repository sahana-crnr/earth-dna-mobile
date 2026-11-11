class ScanPhoto {
  final String view; // top, right, left, sole
  final String? url;
  final int? bytes;
  final String? takenAt;

  ScanPhoto({
    required this.view,
    this.url,
    this.bytes,
    this.takenAt,
  });

  String get viewType => view;

  factory ScanPhoto.fromJson(Map<String, dynamic> json) {
    return ScanPhoto(
      view: json['view'] as String? ?? '',
      url: json['url'] as String?,
      bytes: json['bytes'] as int?,
      takenAt: json['takenAt'] as String?,
    );
  }
}

class ScanShoe {
  final String id;
  final int position;
  final String label;
  final String status;
  final bool complete;
  final List<String> missing;
  final List<ScanPhoto> photos;

  List<ScanPhoto> get views => photos;

  ScanShoe({
    required this.id,
    required this.position,
    required this.label,
    required this.status,
    required this.complete,
    required this.missing,
    required this.photos,
  });

  factory ScanShoe.fromJson(Map<String, dynamic> json) {
    final rawPhotos = json['photos'] as List? ?? [];
    final rawMissing = json['missing'] as List? ?? [];

    return ScanShoe(
      id: json['id'] as String? ?? '',
      position: json['position'] as int? ?? 1,
      label: json['label'] as String? ?? 'Shoe 01',
      status: json['status'] as String? ?? 'capturing',
      complete: json['complete'] as bool? ?? false,
      missing: rawMissing.map((e) => e.toString()).toList(),
      photos: rawPhotos.map((e) => ScanPhoto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  ScanPhoto? photoForView(String view) {
    try {
      return photos.firstWhere((p) => p.view == view);
    } catch (_) {
      return null;
    }
  }
}

class ScanSession {
  final String id;
  final String status; // draft, processing, review, completed
  final bool canFinish;
  final List<ScanShoe> shoes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ScanSession({
    required this.id,
    required this.status,
    required this.canFinish,
    required this.shoes,
    this.createdAt,
    this.updatedAt,
  });

  factory ScanSession.fromJson(Map<String, dynamic> json) {
    final rawShoes = json['shoes'] as List? ?? [];
    return ScanSession(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'draft',
      canFinish: json['canFinish'] as bool? ?? false,
      shoes: rawShoes.map((e) => ScanShoe.fromJson(e as Map<String, dynamic>)).toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }
}

class ShoeDnaResult {
  final String? brand;
  final String? model;
  final String? colorway;
  final int matchPercent;
  final double? confidence;
  final String? conditionCode;
  final String? conditionLabel;
  final String? conditionGrade;

  ShoeDnaResult({
    this.brand,
    this.model,
    this.colorway,
    required this.matchPercent,
    this.confidence,
    this.conditionCode,
    this.conditionLabel,
    this.conditionGrade,
  });

  factory ShoeDnaResult.fromJson(Map<String, dynamic> json) {
    final condition = json['condition'] as Map<String, dynamic>? ?? {};
    return ShoeDnaResult(
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      colorway: json['colorway'] as String?,
      matchPercent: json['matchPercent'] as int? ?? 0,
      confidence: (json['confidence'] as num?)?.toDouble(),
      conditionCode: condition['code'] as String?,
      conditionLabel: condition['label'] as String?,
      conditionGrade: condition['grade'] as String?,
    );
  }
}

