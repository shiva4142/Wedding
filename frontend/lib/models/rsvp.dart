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
        id: j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        attending: j['attending'] as bool? ?? false,
        guests: (j['guests'] as num?)?.toInt() ?? 0,
        message: j['message'] as String? ?? '',
        guestSlug: j['guestSlug'] as String? ?? '',
        createdAt: j['createdAt'] as String? ?? '',
      );

  final String id;
  final String name;
  final String phone;
  final bool attending;
  final int guests;
  final String message;
  final String guestSlug;
  final String createdAt;
}
