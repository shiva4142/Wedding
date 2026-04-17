import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/wedding_config.dart';
import '../models/guest.dart';
import '../models/rsvp.dart';
import '../models/wish.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? WeddingConfig.apiBase;
  final String baseUrl;

  String? _token;
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('admin_token');
    } else {
      await prefs.setString('admin_token', token);
    }
  }

  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('admin_token');
    return _token;
  }

  String? get token => _token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _u(String path, [Map<String, String>? q]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: q);

  // ------------------ Public ------------------

  Future<Rsvp> submitRsvp({
    required String name,
    required String phone,
    required bool attending,
    required int guests,
    String message = '',
    String guestSlug = '',
  }) async {
    final r = await http.post(
      _u('/rsvp'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'attending': attending,
        'guests': guests,
        'message': message,
        'guestSlug': guestSlug,
      }),
    );
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return Rsvp.fromJson(body['rsvp'] as Map<String, dynamic>);
  }

  Future<int> attendingCount() async {
    final r = await http.get(_u('/stats'));
    if (r.statusCode >= 300) return 0;
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return (body['attendingCount'] as num?)?.toInt() ?? 0;
  }

  Future<List<Wish>> listWishes() async {
    final r = await http.get(_u('/wishes'));
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final list = (body['wishes'] as List?) ?? [];
    return list
        .map((e) => Wish.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Wish> sendWish(String name, String message) async {
    final r = await http.post(
      _u('/wishes'),
      headers: _headers,
      body: jsonEncode({'name': name, 'message': message}),
    );
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return Wish.fromJson(body['wish'] as Map<String, dynamic>);
  }

  Future<Guest?> guestBySlug(String slug) async {
    final r = await http.get(_u('/guests/$slug'));
    if (r.statusCode >= 300) return null;
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final g = body['guest'] as Map<String, dynamic>?;
    if (g == null) return null;
    return Guest.fromJson(g);
  }

  // ------------------ Admin ------------------

  Future<String> adminLogin(String email, String password) async {
    final r = await http.post(
      _u('/admin/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final token = body['token'] as String;
    await setToken(token);
    return token;
  }

  Future<Map<String, dynamic>> adminRsvps({String? filter}) async {
    final r = await http.get(
      _u('/admin/rsvps', filter == null ? null : {'filter': filter}),
      headers: _headers,
    );
    if (r.statusCode == 401) throw ApiException('unauthorized');
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<List<Guest>> adminListGuests() async {
    final r = await http.get(_u('/guests'), headers: _headers);
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return ((body['guests'] as List?) ?? [])
        .map((e) => Guest.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Guest> adminAddGuest({
    required String name,
    String phone = '',
    String notes = '',
  }) async {
    final r = await http.post(
      _u('/guests'),
      headers: _headers,
      body: jsonEncode({'name': name, 'phone': phone, 'notes': notes}),
    );
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return Guest.fromJson(body['guest'] as Map<String, dynamic>);
  }

  Future<void> adminDeleteGuest(String id) async {
    await http.delete(_u('/guests'),
        headers: _headers, body: jsonEncode({'id': id}));
  }

  Future<String> adminRemind({
    required String phone,
    required String name,
    required String slug,
    required String siteUrl,
  }) async {
    final r = await http.post(
      _u('/admin/remind'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'name': name,
        'slug': slug,
        'siteUrl': siteUrl,
      }),
    );
    if (r.statusCode >= 300) throw ApiException(_extractError(r));
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    return body['waLink'] as String;
  }

  String exportCsvUrl() => '$baseUrl/admin/export';

  String _extractError(http.Response r) {
    try {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      return body['error']?.toString() ?? 'HTTP ${r.statusCode}';
    } catch (_) {
      return 'HTTP ${r.statusCode}';
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
