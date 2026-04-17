import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dart_frog/dart_frog.dart';

class AdminSession {
  AdminSession({required this.email});
  final String email;
}

String get _jwtSecret =>
    Platform.environment['JWT_SECRET'] ?? 'dev-insecure-secret-change-me';

String get adminEmail =>
    Platform.environment['ADMIN_EMAIL'] ?? 'admin@wedding.com';

String get adminPassword =>
    Platform.environment['ADMIN_PASSWORD'] ?? 'wedding2026';

String signAdminToken(String email) {
  final jwt = JWT({'email': email, 'role': 'admin'});
  return jwt.sign(
    SecretKey(_jwtSecret),
    expiresIn: const Duration(days: 7),
  );
}

AdminSession? verifyAdminToken(String? token) {
  if (token == null || token.isEmpty) return null;
  try {
    final jwt = JWT.verify(token, SecretKey(_jwtSecret));
    final payload = jwt.payload as Map<String, dynamic>;
    return AdminSession(email: payload['email'] as String);
  } catch (_) {
    return null;
  }
}

AdminSession? sessionFromRequest(RequestContext context) {
  final auth = context.request.headers['authorization'];
  if (auth == null || !auth.toLowerCase().startsWith('bearer ')) return null;
  return verifyAdminToken(auth.substring(7));
}

Response unauthorized() => Response.json(
      statusCode: 401,
      body: const {'error': 'Unauthorized'},
    );
