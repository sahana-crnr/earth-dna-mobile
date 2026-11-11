class ShoeCardModel {
  final String id;
  final String brand;
  final String? model;
  final String? color;
  final String? size;
  final String? shoeType;
  final String? conditionCode;
  final String? conditionLabel;
  final String? conditionGrade;
  final String? recommendedAction;
  final double? resaleMin;
  final double? resaleMax;
  final String currency;
  final String? thumbnailUrl;
  final String actionTaken;
  final DateTime? createdAt;

  ShoeCardModel({
    required this.id,
    required this.brand,
    this.model,
    this.color,
    this.size,
    this.shoeType,
    this.conditionCode,
    this.conditionLabel,
    this.conditionGrade,
    this.recommendedAction,
    this.resaleMin,
    this.resaleMax,
    this.currency = 'USD',
    this.thumbnailUrl,
    this.actionTaken = 'none',
    this.createdAt,
  });

  String get brandName => brand;
  String? get primaryPhotoUrl => thumbnailUrl;
  String? get resaleValueFormatted {
    if (resaleMin != null && resaleMax != null) {
      return '\$${resaleMin!.toInt()}–\$${resaleMax!.toInt()}';
    }
    return null;
  }

  String get conditionBadgeText => conditionLabel ?? 'Lightly Worn';

  factory ShoeCardModel.fromJson(Map<String, dynamic> json) {
    String brandName = 'Brand unavailable';
    if (json['brand'] is Map) {
      brandName = json['brand']['name'] as String? ?? 'Brand unavailable';
    } else if (json['brand'] is String) {
      brandName = json['brand'];
    }

    String? sizeLabel;
    if (json['size'] is Map) {
      sizeLabel = json['size']['label'] as String?;
    } else if (json['size'] is String) {
      sizeLabel = json['size'];
    }

    String? typeName;
    if (json['shoeType'] is Map) {
      typeName = json['shoeType']['name'] as String?;
    } else if (json['shoeType'] is String) {
      typeName = json['shoeType'];
    }

    String? condCode;
    String? condLabel;
    String? condGrade;
    if (json['condition'] is Map) {
      condCode = json['condition']['code'] as String?;
      condLabel = json['condition']['label'] as String?;
      condGrade = json['condition']['grade'] as String?;
    }

    double? rMin;
    double? rMax;
    String rCurr = 'USD';
    if (json['resale'] is Map) {
      rMin = (json['resale']['min'] as num?)?.toDouble();
      rMax = (json['resale']['max'] as num?)?.toDouble();
      rCurr = json['resale']['currency'] as String? ?? 'USD';
    } else if (json['value'] is Map) {
      rMin = (json['value']['min'] as num?)?.toDouble();
      rMax = (json['value']['max'] as num?)?.toDouble();
      rCurr = json['value']['currency'] as String? ?? 'USD';
    }

    String? recAction;
    if (json['recommendedAction'] is String) {
      recAction = json['recommendedAction'];
    } else if (json['recommendation'] is Map) {
      recAction = json['recommendation']['action'] as String?;
    }

    DateTime? created;
    if (json['createdAt'] != null) {
      created = DateTime.tryParse(json['createdAt'] as String);
    }

    return ShoeCardModel(
      id: json['id'] as String? ?? '',
      brand: brandName,
      model: json['model'] as String?,
      color: json['color'] as String?,
      size: sizeLabel,
      shoeType: typeName,
      conditionCode: condCode,
      conditionLabel: condLabel,
      conditionGrade: condGrade,
      recommendedAction: recAction,
      resaleMin: rMin,
      resaleMax: rMax,
      currency: rCurr,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      actionTaken: json['actionTaken'] as String? ?? 'none',
      createdAt: created,
    );
  }
}

class ShoePhotoModel {
  final String id;
  final String? view; // top, right, left, sole
  final String? url;
  final int? sortOrder;

  ShoePhotoModel({
    required this.id,
    this.view,
    this.url,
    this.sortOrder,
  });

  factory ShoePhotoModel.fromJson(Map<String, dynamic> json) {
    return ShoePhotoModel(
      id: json['id'] as String? ?? '',
      view: json['view'] as String?,
      url: json['url'] as String?,
      sortOrder: json['sortOrder'] as int?,
    );
  }
}

class ShoeProfileModel {
  final String id;
  final String brand;
  final String? model;
  final String? shoeType;
  final String? color;
  final String? size;
  final String? gender;
  final String? conditionCode;
  final String? conditionLabel;
  final String? conditionGrade;
  final String? conditionDescription;
  final double? resaleMin;
  final double? resaleMax;
  final String currency;
  final String? demandNote;
  final String? recommendedAction;
  final String? recommendationReason;
  final List<ShoePhotoModel> photos;
  final String actionTaken;
  final Map<String, dynamic>? share;

  ShoeProfileModel({
    required this.id,
    required this.brand,
    this.model,
    this.shoeType,
    this.color,
    this.size,
    this.gender,
    this.conditionCode,
    this.conditionLabel,
    this.conditionGrade,
    this.conditionDescription,
    this.resaleMin,
    this.resaleMax,
    this.currency = 'USD',
    this.demandNote,
    this.recommendedAction,
    this.recommendationReason,
    required this.photos,
    this.actionTaken = 'none',
    this.share,
  });

  String? get resaleValueFormatted {
    if (resaleMin != null && resaleMax != null) {
      return '\$${resaleMin!.toInt()}–\$${resaleMax!.toInt()}';
    }
    return null;
  }

  String get conditionBadgeText => conditionLabel ?? 'Lightly Worn';

  factory ShoeProfileModel.fromJson(Map<String, dynamic> json) {
    String brandName = 'Brand unavailable';
    if (json['brand'] is Map) {
      brandName = json['brand']['name'] as String? ?? 'Brand unavailable';
    } else if (json['brand'] is String) {
      brandName = json['brand'];
    }

    String? sizeLabel;
    if (json['size'] is Map) {
      sizeLabel = json['size']['label'] as String?;
    } else if (json['size'] is String) {
      sizeLabel = json['size'];
    }

    String? typeName;
    if (json['shoeType'] is Map) {
      typeName = json['shoeType']['name'] as String?;
    } else if (json['shoeType'] is String) {
      typeName = json['shoeType'];
    }

    String? condCode;
    String? condLabel;
    String? condGrade;
    String? condDesc;
    if (json['condition'] is Map) {
      condCode = json['condition']['code'] as String?;
      condLabel = json['condition']['label'] as String?;
      condGrade = json['condition']['grade'] as String?;
      condDesc = json['condition']['description'] as String?;
    }

    double? rMin;
    double? rMax;
    String rCurr = 'USD';
    String? dNote;
    if (json['value'] is Map) {
      rMin = (json['value']['min'] as num?)?.toDouble();
      rMax = (json['value']['max'] as num?)?.toDouble();
      rCurr = json['value']['currency'] as String? ?? 'USD';
      dNote = json['value']['demandNote'] as String?;
    }

    String? recAction;
    String? recReason;
    if (json['recommendation'] is Map) {
      recAction = json['recommendation']['action'] as String?;
      recReason = json['recommendation']['reason'] as String?;
    }

    final rawPhotos = json['photos'] as List? ?? [];
    return ShoeProfileModel(
      id: json['id'] as String? ?? '',
      brand: brandName,
      model: json['model'] as String?,
      shoeType: typeName,
      color: json['color'] as String?,
      size: sizeLabel,
      gender: json['gender'] as String?,
      conditionCode: condCode,
      conditionLabel: condLabel,
      conditionGrade: condGrade,
      conditionDescription: condDesc,
      resaleMin: rMin,
      resaleMax: rMax,
      currency: rCurr,
      demandNote: dNote,
      recommendedAction: recAction,
      recommendationReason: recReason,
      photos: rawPhotos.map((e) => ShoePhotoModel.fromJson(e as Map<String, dynamic>)).toList(),
      actionTaken: json['actionTaken'] as String? ?? 'none',
      share: json['share'] as Map<String, dynamic>?,
    );
  }
}

class ShoeSummaryModel {
  final int pairsScanned;
  final double? potentialValueMin;
  final double? potentialValueMax;
  final String currency;

  ShoeSummaryModel({
    required this.pairsScanned,
    this.potentialValueMin,
    this.potentialValueMax,
    this.currency = 'USD',
  });

  int get totalShoes => pairsScanned;
  int get totalResaleValue => potentialValueMax?.toInt() ?? 0;

  factory ShoeSummaryModel.fromJson(Map<String, dynamic> json) {
    double? min;
    double? max;
    String curr = 'USD';
    if (json['potentialValue'] is Map) {
      min = (json['potentialValue']['min'] as num?)?.toDouble();
      max = (json['potentialValue']['max'] as num?)?.toDouble();
      curr = json['potentialValue']['currency'] as String? ?? 'USD';
    }

    return ShoeSummaryModel(
      pairsScanned: json['pairsScanned'] as int? ?? 0,
      potentialValueMin: min,
      potentialValueMax: max,
      currency: curr,
    );
  }
}
