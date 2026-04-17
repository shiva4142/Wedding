import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:wedding_backend/auth.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'] as String?;
  final password = body['password'] as String?;
  if (email != adminEmail || password != adminPassword) {
    return Response.json(
      statusCode: HttpStatus.unauthorized,
      body: const {'error': 'Invalid credentials'},
    );
  }
  final token = signAdminToken(email!);
  return Response.json(body: {'ok': true, 'token': token, 'email': email});
}
