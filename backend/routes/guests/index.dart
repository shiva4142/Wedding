import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context) async {
  final session = sessionFromRequest(context);
  if (session == null) return unauthorized();

  final store = context.read<Store>();
  final method = context.request.method;

  if (method == HttpMethod.get) {
    final guests = await store.listGuests();
    return Response.json(body: {
      'ok': true,
      'guests': guests.map((g) => g.toJson()).toList(),
    });
  }

  if (method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final name = (body['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: const {'error': 'name required'},
      );
    }
    final g = await store.addGuest({
      'name': name,
      'phone': body['phone'] ?? '',
      'notes': body['notes'] ?? '',
    });
    return Response.json(body: {'ok': true, 'guest': g.toJson()});
  }

  if (method == HttpMethod.delete) {
    final body = await context.request.json() as Map<String, dynamic>;
    final id = body['id'] as String?;
    if (id == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: const {'error': 'id required'},
      );
    }
    await store.deleteGuest(id);
    return Response.json(body: const {'ok': true});
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
