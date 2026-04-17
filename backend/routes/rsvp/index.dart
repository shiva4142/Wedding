import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  final store = context.read<Store>();
  if (method == HttpMethod.post) return _post(context, store);
  if (method == HttpMethod.get) return _get(context, store);
  return Response(statusCode: HttpStatus.methodNotAllowed);
}

Future<Response> _post(RequestContext context, Store store) async {
  try {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = (body['name'] as String?)?.trim() ?? '';
    final phone = (body['phone'] as String?)?.trim() ?? '';
    final attending = body['attending'] as bool?;
    if (name.isEmpty || phone.isEmpty || attending == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: const {'error': 'name, phone and attending are required'},
      );
    }
    final rsvp = await store.upsertRsvp({
      'name': name,
      'phone': phone,
      'attending': attending,
      'guests': body['guests'],
      'message': body['message'],
      'guestSlug': body['guestSlug'],
    });
    return Response.json(body: {'ok': true, 'rsvp': rsvp.toJson()});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': e.toString()},
    );
  }
}

Future<Response> _get(RequestContext context, Store store) async {
  // Public-safe: only returns counts; full list reserved for /admin/rsvps.
  final session = sessionFromRequest(context);
  if (session == null) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: const {'error': 'Use /stats for public counts'},
    );
  }
  final rsvps = await store.listRsvps();
  return Response.json(body: {
    'ok': true,
    'rsvps': rsvps.map((r) => r.toJson()).toList(),
  });
}
