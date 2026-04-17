/// Domain models shared across the backend.
class Rsvp {
  Rsvp({
    required this.id,
    required this.name,
    required this.phone,
    required this.attending,
    required this.guests,
    required this.message,
    required this.guestSlug,
    required this.createdAt,
  });

  factory Rsvp.fromJson(Map<String, dynamic> j) => Rsvp(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        attending: j['attending'] as bool? ?? false,
        guests: (j['guests'] as num?)?.toInt() ?? 0,
        message: j['message'] as String? ?? '',
        guestSlug: j['guestSlug'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String id;
  final String name;
  final String phone;
  final bool attending;
  final int guests;
  final String message;
  final String guestSlug;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'attending': attending,
        'guests': guests,
        'message': message,
        'guestSlug': guestSlug,
        'createdAt': createdAt,
      };
}

class Wish {
  Wish({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
  });

  factory Wish.fromJson(Map<String, dynamic> j) => Wish(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        message: j['message'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String id;
  final String name;
  final String message;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'message': message,
        'createdAt': createdAt,
      };
}

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
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        slug: j['slug'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        notes: j['notes'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String id;
  final String name;
  final String slug;
  final String phone;
  final String notes;
  final String createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'phone': phone,
        'notes': notes,
        'createdAt': createdAt,
      };
}
