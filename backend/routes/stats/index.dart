import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context) async {
  final store = context.read<Store>();
  final rsvps = await store.listRsvps();
  final attendingCount = rsvps
      .where((r) => r.attending)
      .fold<int>(0, (a, r) => a + (r.guests > 0 ? r.guests : 1));
  final declined = rsvps.where((r) => !r.attending).length;
  return Response.json(body: {
    'ok': true,
    'attendingCount': attendingCount,
    'declined': declined,
    'totalResponses': rsvps.length,
  });
}
