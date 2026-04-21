import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';

/// Generates a `wa.me` deep-link with a personalized RSVP reminder message
/// the admin can send with one click. Replace this with the WhatsApp
/// Business Cloud API for fully automated sending.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  final session = sessionFromRequest(context);
  if (session == null) return unauthorized();

  final body = await context.request.json() as Map<String, dynamic>;
  final phone = (body['phone'] as String?)?.trim() ?? '';
  if (phone.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: const {'error': 'phone required'},
    );
  }
  final name = body['name'] as String? ?? 'there';
  final slug = body['slug'] as String? ?? '';
  final siteUrl =
      body['siteUrl'] as String? ?? Platform.environment['SITE_URL'] ?? '';
  final coupleBride =
      Platform.environment['COUPLE_BRIDE'] ?? 'Pooja';
  final coupleGroom =
      Platform.environment['COUPLE_GROOM'] ?? 'Shiva';

  final inviteUrl = '$siteUrl/invite?guest=${Uri.encodeQueryComponent(slug)}';
  final text =
      "Hi $name! A gentle reminder to RSVP for $coupleBride & $coupleGroom's wedding. Please take a moment: $inviteUrl";
  final waLink =
      'https://wa.me/${phone.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeQueryComponent(text)}';

  return Response.json(body: {
    'ok': true,
    'simulated': true,
    'waLink': waLink,
    'message': 'Reminder ready for $name',
  });
}
