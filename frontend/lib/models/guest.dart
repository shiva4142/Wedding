class Guest {
  Guest({
    required this.id,
    required this.name,
    required this.slug,
    required this.phone,
    required this.notes,
    required this.createdAt,
  });

  factory Guest.fromJson(Map<String, dynamic> j) => Guest(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        slug: j['slug'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? '',
      );

  final String id;
  final String name;
  final String slug;
  final String phone;
  final String notes;
  final String createdAt;
}
