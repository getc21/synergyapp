/// Modelo de Marca (Brand) para multi-tenant SaaS.
/// Cada marca es la entidad raíz que agrupa tiendas, usuarios y recursos.
class Brand {
  final String? id;
  final String name;
  final String slug;
  final String? logo;
  final String contactEmail;
  final String? phone;
  final String? address;
  final int maxStores;
  final String plan; // 'basic' | 'pro' | 'enterprise'
  final bool isActive;
  final BrandSettings settings;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Brand({
    this.id,
    required this.name,
    required this.slug,
    this.logo,
    required this.contactEmail,
    this.phone,
    this.address,
    this.maxStores = 3,
    this.plan = 'basic',
    this.isActive = true,
    BrandSettings? settings,
    DateTime? createdAt,
    this.updatedAt,
  })  : settings = settings ?? BrandSettings(),
        createdAt = createdAt ?? DateTime.now();

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      logo: map['logo'],
      contactEmail: map['contactEmail'] ?? '',
      phone: map['phone'],
      address: map['address'],
      maxStores: (map['maxStores'] ?? 3) as int,
      plan: map['plan'] ?? 'basic',
      isActive: map['isActive'] ?? true,
      settings: map['settings'] != null
          ? BrandSettings.fromMap(Map<String, dynamic>.from(map['settings']))
          : BrandSettings(),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) '_id': id,
      'name': name,
      'slug': slug,
      if (logo != null) 'logo': logo,
      'contactEmail': contactEmail,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      'maxStores': maxStores,
      'plan': plan,
      'isActive': isActive,
      'settings': settings.toMap(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Brand copyWith({
    String? id,
    String? name,
    String? slug,
    String? logo,
    String? contactEmail,
    String? phone,
    String? address,
    int? maxStores,
    String? plan,
    bool? isActive,
    BrandSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      logo: logo ?? this.logo,
      contactEmail: contactEmail ?? this.contactEmail,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      maxStores: maxStores ?? this.maxStores,
      plan: plan ?? this.plan,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Label amigable para el plan
  String get planDisplay {
    switch (plan) {
      case 'basic':
        return 'Básico';
      case 'pro':
        return 'Profesional';
      case 'enterprise':
        return 'Empresa';
      default:
        return plan;
    }
  }

  @override
  String toString() =>
      'Brand{id: $id, name: $name, slug: $slug, plan: $plan, isActive: $isActive}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Brand && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Configuración personalizada por marca
class BrandSettings {
  final String currency;
  final String timezone;
  final String language;

  BrandSettings({
    this.currency = 'BOB',
    this.timezone = 'America/La_Paz',
    this.language = 'es',
  });

  factory BrandSettings.fromMap(Map<String, dynamic> map) {
    return BrandSettings(
      currency: map['currency'] ?? 'BOB',
      timezone: map['timezone'] ?? 'America/La_Paz',
      language: map['language'] ?? 'es',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'currency': currency,
      'timezone': timezone,
      'language': language,
    };
  }
}
