import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/store.dart';

Future<Response> onRequest(RequestContext context) async {
  final store = context.read<Store>();
  final method = context.request.method;

  if (method == HttpMethod.get) {
    final wishes = await store.listWishes();
    return Response.json(body: {
      'ok': true,
      'wishes': wishes.map((w) => w.toJson()).toList(),
    });
  }

  if (method == HttpMethod.post) {
    try {
      final body = await context.request.json() as Map<String, dynamic>;
      final name = (body['name'] as String?)?.trim() ?? '';
      final message = (body['message'] as String?)?.trim() ?? '';
      if (name.isEmpty || message.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: const {'error': 'name and message required'},
        );
      }
      final wish = await store.addWish({
        'name': name.length > 80 ? name.substring(0, 80) : name,
        'message':
            message.length > 500 ? message.substring(0, 500) : message,
      });
      return Response.json(body: {'ok': true, 'wish': wish.toJson()});
    } catch (e) {
      return Response.json(
        statusCode: HttpStatus.internalServerError,
        body: {'error': e.toString()},
      );
    }
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
