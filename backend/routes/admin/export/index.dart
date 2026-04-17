import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';
import 'package:wedding_backend/store.dart';

AdminSession? _sessionFromAnywhere(RequestContext context) {
  final fromHeader = sessionFromRequest(context);
  if (fromHeader != null) return fromHeader;
  final tokenQuery = context.request.uri.queryParameters['token'];
  return verifyAdminToken(tokenQuery);
}

String _csvCell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

Future<Response> onRequest(RequestContext context) async {
  final session = _sessionFromAnywhere(context);
  if (session == null) return unauthorized();

  final rsvps = await context.read<Store>().listRsvps();
  final header = [
    'Name',
    'Phone',
    'Attending',
    'Guests',
    'Message',
    'Guest Slug',
    'Submitted At',
  ];

  final lines = <String>[header.map(_csvCell).join(',')];
  for (final r in rsvps) {
    lines.add([
      _csvCell(r.name),
      _csvCell(r.phone),
      _csvCell(r.attending ? 'Yes' : 'No'),
      _csvCell(r.guests.toString()),
      _csvCell(r.message),
      _csvCell(r.guestSlug),
      _csvCell(r.createdAt),
    ].join(','));
  }

  return Response(
    body: lines.join('\n'),
    headers: {
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition':
          'attachment; filename="rsvps-${DateTime.now().millisecondsSinceEpoch}.csv"',
    },
  );
}
