class Store {
  final String? id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final String? brandId; // ⭐ MULTI-TENANT
  final String status;
  final DateTime createdAt;

  Store({
    this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.brandId,
    this.status = 'active',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Crear Store desde Map
  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      name: map['name'] as String,
      address: map['address'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      brandId: map['brandId']?.toString(),
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.tryParse(map['createdAt'] ?? map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  // Convertir Store a Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (id != null) '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      if (brandId != null) 'brandId': brandId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Método copyWith para crear copias con modificaciones
  Store copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? brandId,
    String? status,
    DateTime? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      brandId: brandId ?? this.brandId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isActive => status == 'active';

  @override
  String toString() {
    return 'Store{id: $id, name: $name, address: $address, phone: $phone, email: $email, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
