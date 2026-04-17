import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context) async {
  final session = sessionFromRequest(context);
  if (session == null) return unauthorized();

  final store = context.read<Store>();
  final query = context.request.uri.queryParameters;
  final filter = query['filter'];

  var rsvps = await store.listRsvps();
  if (filter == 'yes') rsvps = rsvps.where((r) => r.attending).toList();
  if (filter == 'no') rsvps = rsvps.where((r) => !r.attending).toList();

  final attendingCount = rsvps
      .where((r) => r.attending)
      .fold<int>(0, (a, r) => a + (r.guests > 0 ? r.guests : 1));
  final declinedCount = rsvps.where((r) => !r.attending).length;

  final allGuests = await store.listGuests();
  final respondedSlugs = (await store.listRsvps())
      .map((r) => r.guestSlug)
      .where((s) => s.isNotEmpty)
      .toSet();
  final respondedPhones = (await store.listRsvps()).map((r) => r.phone).toSet();
  final notResponded = allGuests
      .where((g) =>
          !respondedSlugs.contains(g.slug) &&
          (g.phone.isEmpty || !respondedPhones.contains(g.phone)))
      .toList();

  return Response.json(body: {
    'ok': true,
    'total': rsvps.length,
    'attendingCount': attendingCount,
    'declinedCount': declinedCount,
    'rsvps': rsvps.map((r) => r.toJson()).toList(),
    'notResponded': notResponded.map((g) => g.toJson()).toList(),
  });
}
