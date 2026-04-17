class Wish {
  Wish({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
  });

  factory Wish.fromJson(Map<String, dynamic> j) => Wish(
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        message: j['message'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? '',
      );

  final String id;
  final String name;
  final String message;
  final String createdAt;
}
