import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:wedding_backend/models.dart';
import 'package:wedding_backend/store.dart';

/// Firestore-backed [Store] using the Firestore REST API.
/// Lightweight: avoids native admin SDK dependencies. For production hardening
/// you should use Firestore Security Rules to allow only this backend's
/// service-account-issued tokens; the simple setup below uses a project API key
/// and assumes rules are open for the relevant collections (or you'll add
/// Firebase Auth to mediate).
class FirestoreStore implements Store {
  FirestoreStore({required this.projectId, required this.apiKey});

  final String projectId;
  final String apiKey;
  static const _uuid = Uuid();

  String get _base =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  // ---------- low-level helpers ----------

  Map<String, dynamic> _toFirestoreFields(Map<String, dynamic> map) {
    final fields = <String, dynamic>{};
    map.forEach((k, v) {
      fields[k] = _toFirestoreValue(v);
    });
    return {'fields': fields};
  }

  Map<String, dynamic> _toFirestoreValue(dynamic v) {
    if (v == null) return {'nullValue': null};
    if (v is bool) return {'booleanValue': v};
    if (v is int) return {'integerValue': v.toString()};
    if (v is double) return {'doubleValue': v};
    if (v is String) return {'stringValue': v};
    if (v is List) {
      return {
        'arrayValue': {'values': v.map(_toFirestoreValue).toList()},
      };
    }
    if (v is Map) {
      final inner = <String, dynamic>{};
      v.forEach((k, vv) => inner[k.toString()] = _toFirestoreValue(vv));
      return {
        'mapValue': {'fields': inner},
      };
    }
    return {'stringValue': v.toString()};
  }

  Map<String, dynamic> _fromFirestoreDoc(Map<String, dynamic> doc) {
    final fields = (doc['fields'] as Map?) ?? {};
    final out = <String, dynamic>{};
    fields.forEach((k, v) {
      out[k as String] = _fromFirestoreValue(v as Map<String, dynamic>);
    });
    final name = doc['name'] as String?;
    if (name != null) {
      out['_id'] = name.split('/').last;
    }
    return out;
  }

  dynamic _fromFirestoreValue(Map<String, dynamic> v) {
    if (v.containsKey('nullValue')) return null;
    if (v.containsKey('booleanValue')) return v['booleanValue'];
    if (v.containsKey('integerValue')) {
      return int.tryParse(v['integerValue'].toString());
    }
    if (v.containsKey('doubleValue')) return v['doubleValue'];
    if (v.containsKey('stringValue')) return v['stringValue'];
    if (v.containsKey('arrayValue')) {
      final values = (v['arrayValue']['values'] as List?) ?? [];
      return values
          .map((e) => _fromFirestoreValue(e as Map<String, dynamic>))
          .toList();
    }
    if (v.containsKey('mapValue')) {
      final inner = (v['mapValue']['fields'] as Map?) ?? {};
      final m = <String, dynamic>{};
      inner.forEach((k, vv) =>
          m[k as String] = _fromFirestoreValue(vv as Map<String, dynamic>));
      return m;
    }
    return null;
  }

  Future<Map<String, dynamic>> _create(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse(
      '$_base/$collection?documentId=$docId&key=$apiKey',
    );
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_toFirestoreFields(data)),
    );
    if (res.statusCode >= 300) {
      throw Exception('Firestore create failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _list(String collection) async {
    final url = Uri.parse('$_base/$collection?key=$apiKey&pageSize=300');
    final res = await http.get(url);
    if (res.statusCode == 404) return [];
    if (res.statusCode >= 300) {
      throw Exception('Firestore list failed: ${res.statusCode} ${res.body}');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final docs = (body['documents'] as List?) ?? [];
    return docs
        .map((d) => _fromFirestoreDoc(d as Map<String, dynamic>))
        .toList();
  }

  Future<void> _delete(String collection, String id) async {
    final url = Uri.parse('$_base/$collection/$id?key=$apiKey');
    await http.delete(url);
  }

  Future<void> _patch(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$_base/$collection/$id?key=$apiKey');
    final res = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(_toFirestoreFields(data)),
    );
    if (res.statusCode >= 300) {
      throw Exception('Firestore patch failed: ${res.statusCode} ${res.body}');
    }
  }

  // ---------- Store interface ----------

  @override
  Future<List<Rsvp>> listRsvps() async {
    final docs = await _list('rsvps');
    final list = docs.map((d) {
      d['id'] = d['_id'];
      return Rsvp.fromJson(d);
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Rsvp> upsertRsvp(Map<String, dynamic> data) async {
    final phone = (data['phone'] as String).trim();
    final all = await listRsvps();
    final existing = all.where((r) => r.phone == phone).toList();
    final id = existing.isNotEmpty ? existing.first.id : _uuid.v4();
    final now = existing.isNotEmpty
        ? existing.first.createdAt
        : DateTime.now().toIso8601String();
    final payload = {
      'name': data['name'],
      'phone': phone,
      'attending': data['attending'],
      'guests': (data['guests'] as num?)?.toInt() ??
          (data['attending'] == true ? 1 : 0),
      'message': data['message'] ?? '',
      'guestSlug': data['guestSlug'] ?? '',
      'createdAt': now,
    };
    if (existing.isNotEmpty) {
      await _patch('rsvps', id, payload);
    } else {
      await _create('rsvps', id, payload);
    }
    return Rsvp(
      id: id,
      name: payload['name']! as String,
      phone: phone,
      attending: payload['attending']! as bool,
      guests: payload['guests']! as int,
      message: payload['message']! as String,
      guestSlug: payload['guestSlug']! as String,
      createdAt: now,
    );
  }

  @override
  Future<List<Wish>> listWishes() async {
    final docs = await _list('wishes');
    final list = docs.map((d) {
      d['id'] = d['_id'];
      return Wish.fromJson(d);
    }).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<Wish> addWish(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final payload = {
      'name': (data['name'] as String).trim(),
      'message': (data['message'] as String).trim(),
      'createdAt': now,
    };
    await _create('wishes', id, payload);
    return Wish(
      id: id,
      name: payload['name']! as String,
      message: payload['message']! as String,
      createdAt: now,
    );
  }

  @override
  Future<List<Guest>> listGuests() async {
    final docs = await _list('guests');
    return docs.map((d) {
      d['id'] = d['_id'];
      return Guest.fromJson(d);
    }).toList();
  }

  @override
  Future<Guest> addGuest(Map<String, dynamic> data) async {
    final id = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    final name = (data['name'] as String).trim();
    final slug = '${slugify(name)}-${id.substring(0, 4)}';
    final payload = {
      'name': name,
      'slug': slug,
      'phone': (data['phone'] as String?) ?? '',
      'notes': (data['notes'] as String?) ?? '',
      'createdAt': now,
    };
    await _create('guests', id, payload);
    return Guest(
      id: id,
      name: name,
      slug: slug,
      phone: payload['phone']! as String,
      notes: payload['notes']! as String,
      createdAt: now,
    );
  }

  @override
  Future<void> deleteGuest(String id) => _delete('guests', id);

  @override
  Future<Guest?> guestBySlug(String slug) async {
    final all = await listGuests();
    try {
      return all.firstWhere((g) => g.slug == slug);
    } catch (_) {
      return null;
    }
  }
}
