import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context, String slug) async {
  final store = context.read<Store>();
  final guest = await store.guestBySlug(slug);
  if (guest != null) {
    return Response.json(body: {'ok': true, 'guest': guest.toJson()});
  }
  // Friendly fallback so personalization still works for unknown slugs.
  final name = slug
      .split('-')
      .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ')
      .trim();
  return Response.json(body: {
    'ok': true,
    'guest': {'name': name, 'slug': slug, 'phone': '', 'id': '', 'notes': ''},
    'unknown': true,
  });
}
