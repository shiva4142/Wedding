import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:wedding_backend/models.dart';
import 'package:wedding_backend/store.dart';

/// Supabase-backed [Store] using PostgREST endpoints.
///
/// Required env vars:
///   SUPABASE_URL   e.g. https://xxxx.supabase.co
///   SUPABASE_KEY   service-role key (sb_secret_...)
class SupabaseStore implements Store {
  SupabaseStore({required this.url, required this.key});

  final String url;
  final String key;
  static const _uuid = Uuid();

  Uri _u(String table, [Map<String, String>? q]) =>
      Uri.parse('$url/rest/v1/$table').replace(queryParameters: q);

  Map<String, String> get _headers => {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      };

  Future<List<Map<String, dynamic>>> _list(
    String table, {
    required String select,
    String? orderBy,
    bool ascending = false,
    Map<String, String>? filters,
  }) async {
    final q = <String, String>{
      'select': select,
      if (orderBy != null) 'order': '$orderBy.${ascending ? 'asc' : 'desc'}',
      ...?filters,
    };
    final res = await http.get(_u(table, q), headers: _headers);
    if (res.statusCode >= 300) {
      throw Exception('Supabase list failed [$table]: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is! List) return const [];
    return body.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> _insert(
    String table,
    Map<String, dynamic> row,
  ) async {
    final res = await http.post(
      _u(table, {'select': '*'}),
      headers: {
        ..._headers,
        'Prefer': 'return=representation',
      },
      body: jsonEncode(row),
    );
    if (res.statusCode >= 300) {
      throw Exception('Supabase insert failed [$table]: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is List && body.isNotEmpty) return body.first as Map<String, dynamic>;
    return row;
  }

  Future<Map<String, dynamic>> _updateById(
    String table,
    String id,
    Map<String, dynamic> patch,
  ) async {
    final res = await http.patch(
      _u(table, {'id': 'eq.$id', 'select': '*'}),
      headers: {
        ..._headers,
        'Prefer': 'return=representation',
      },
      body: jsonEncode(patch),
    );
    if (res.statusCode >= 300) {
      throw Exception('Supabase patch failed [$table]: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is List && body.isNotEmpty) return body.first as Map<String, dynamic>;
    return patch;
  }

  Future<void> _deleteById(String table, String id) async {
    final res = await http.delete(
      _u(table, {'id': 'eq.$id'}),
      headers: _headers,
    );
    if (res.statusCode >= 300) {
      throw Exception('Supabase delete failed [$table]: ${res.statusCode} ${res.body}');
    }
  }

  String _nowIso() => DateTime.now().toIso8601String();

  @override
  Future<List<Rsvp>> listRsvps() async {
    final rows = await _list(
      'rsvps',
      select: 'id,name,phone,attending,guests,message,guest_slug,created_at',
      orderBy: 'created_at',
    );
    return rows
        .map(
          (r) => Rsvp.fromJson({
            'id': (r['id'] ?? '').toString(),
            'name': (r['name'] ?? '').toString(),
            'phone': (r['phone'] ?? '').toString(),
            'attending': r['attending'] == true,
            'guests': (r['guests'] as num?)?.toInt() ?? 0,
            'message': (r['message'] ?? '').toString(),
            'guestSlug': (r['guest_slug'] ?? '').toString(),
            'createdAt': (r['created_at'] ?? _nowIso()).toString(),
          }),
        )
        .toList();
  }

  @override
  Future<Rsvp> upsertRsvp(Map<String, dynamic> data) async {
    final phone = (data['phone'] as String).trim();
    final existing = await _list(
      'rsvps',
      select: 'id,created_at',
      filters: {'phone': 'eq.$phone'},
    );
    final existingId = existing.isNotEmpty ? (existing.first['id'] as String?) : null;
    final createdAt = existing.isNotEmpty
        ? (existing.first['created_at'] ?? _nowIso()).toString()
        : _nowIso();

    final row = <String, dynamic>{
      'name': data['name'],
      'phone': phone,
      'attending': data['attending'] == true,
      'guests': (data['guests'] as num?)?.toInt() ??
          (data['attending'] == true ? 1 : 0),
      'message': (data['message'] ?? '').toString(),
      'guest_slug': (data['guestSlug'] ?? '').toString(),
      'created_at': createdAt,
    };

    Map<String, dynamic> saved;
    if (existingId != null && existingId.isNotEmpty) {
      saved = await _updateById('rsvps', existingId, row);
    } else {
      saved = await _insert('rsvps', {'id': _uuid.v4(), ...row});
    }

    return Rsvp.fromJson({
      'id': (saved['id'] ?? '').toString(),
      'name': (saved['name'] ?? '').toString(),
      'phone': (saved['phone'] ?? '').toString(),
      'attending': saved['attending'] == true,
      'guests': (saved['guests'] as num?)?.toInt() ?? 0,
      'message': (saved['message'] ?? '').toString(),
      'guestSlug': (saved['guest_slug'] ?? '').toString(),
      'createdAt': (saved['created_at'] ?? createdAt).toString(),
    });
  }

  @override
  Future<List<Wish>> listWishes() async {
    final rows = await _list(
      'wishes',
      select: 'id,name,message,created_at',
      orderBy: 'created_at',
    );
    return rows
        .map(
          (r) => Wish.fromJson({
            'id': (r['id'] ?? '').toString(),
            'name': (r['name'] ?? '').toString(),
            'message': (r['message'] ?? '').toString(),
            'createdAt': (r['created_at'] ?? _nowIso()).toString(),
          }),
        )
        .toList();
  }

  @override
  Future<Wish> addWish(Map<String, dynamic> data) async {
    final saved = await _insert('wishes', {
      'id': _uuid.v4(),
      'name': (data['name'] as String).trim(),
      'message': (data['message'] as String).trim(),
      'created_at': _nowIso(),
    });
    return Wish.fromJson({
      'id': (saved['id'] ?? '').toString(),
      'name': (saved['name'] ?? '').toString(),
      'message': (saved['message'] ?? '').toString(),
      'createdAt': (saved['created_at'] ?? _nowIso()).toString(),
    });
  }

  @override
  Future<List<Guest>> listGuests() async {
    final rows = await _list(
      'guests',
      select: 'id,name,slug,phone,notes,created_at',
      orderBy: 'created_at',
    );
    return rows
        .map(
          (r) => Guest.fromJson({
            'id': (r['id'] ?? '').toString(),
            'name': (r['name'] ?? '').toString(),
            'slug': (r['slug'] ?? '').toString(),
            'phone': (r['phone'] ?? '').toString(),
            'notes': (r['notes'] ?? '').toString(),
            'createdAt': (r['created_at'] ?? _nowIso()).toString(),
          }),
        )
        .toList();
  }

  @override
  Future<Guest> addGuest(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    final name = (data['name'] as String).trim();
    final row = <String, dynamic>{
      'id': id,
      'name': name,
      'slug': '${slugify(name)}-${id.substring(0, 4)}',
      'phone': (data['phone'] as String?)?.trim() ?? '',
      'notes': (data['notes'] as String?)?.trim() ?? '',
      'created_at': _nowIso(),
    };
    final saved = await _insert('guests', row);
    return Guest.fromJson({
      'id': (saved['id'] ?? '').toString(),
      'name': (saved['name'] ?? '').toString(),
      'slug': (saved['slug'] ?? '').toString(),
      'phone': (saved['phone'] ?? '').toString(),
      'notes': (saved['notes'] ?? '').toString(),
      'createdAt': (saved['created_at'] ?? _nowIso()).toString(),
    });
  }

  @override
  Future<void> deleteGuest(String id) => _deleteById('guests', id);

  @override
  Future<Guest?> guestBySlug(String slug) async {
    final rows = await _list(
      'guests',
      select: 'id,name,slug,phone,notes,created_at',
      filters: {'slug': 'eq.$slug'},
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return Guest.fromJson({
      'id': (r['id'] ?? '').toString(),
      'name': (r['name'] ?? '').toString(),
      'slug': (r['slug'] ?? '').toString(),
      'phone': (r['phone'] ?? '').toString(),
      'notes': (r['notes'] ?? '').toString(),
      'createdAt': (r['created_at'] ?? _nowIso()).toString(),
    });
  }
}
