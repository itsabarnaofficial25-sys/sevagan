class ServiceCategory {
  final String id;
  final String name;
  final String nameEn;
  final String nameTa;
  final String? description;
  final String? descriptionTa;  
  final double basePrice;
  final double minPrice;
  final double maxPrice;
  final double commissionPercent;
  final String commissionType;
  final double? commissionAmount;
  final String? iconUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameTa,
    this.description,
    this.descriptionTa,
    required this.basePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.commissionPercent,
    required this.commissionType,
    this.commissionAmount,
    this.iconUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'].toString(),
      name: json['name'] ?? json['nameEn'] ?? '',
      nameEn: json['nameEn'] ?? json['name'] ?? '',
      nameTa: json['nameTa'] ?? '',
      description: json['description'],
      descriptionTa: json['descriptionTa'],  // ← ADD THIS
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      minPrice: (json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0).toDouble(),
      commissionPercent: (json['commissionPercent'] ?? 0).toDouble(),
      commissionType: json['commissionType'] ?? 'PERCENTAGE',
      commissionAmount: json['commissionAmount']?.toDouble(),
      iconUrl: json['iconUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // Helper method to get description based on language
  String getDescription(String languageCode) {
    if (languageCode == 'ta' && descriptionTa != null && descriptionTa!.isNotEmpty) {
      return descriptionTa!;
    }
    return description ?? '';
  }
}