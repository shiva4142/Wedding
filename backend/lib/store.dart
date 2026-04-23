import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:wedding_backend/models.dart';
import 'package:wedding_backend/firestore_rest.dart';
import 'package:wedding_backend/supabase_rest.dart';

/// A unified data store that uses Firestore (REST API) when configured,
/// otherwise falls back to an in-memory store seeded with sample data.
///
/// To enable Firestore set both env vars:
///   FIREBASE_PROJECT_ID
///   FIREBASE_API_KEY     (Web API key from Firebase project settings)
///
/// Then in your Firestore rules allow unauthenticated writes from the backend
/// (or wire a service account). See README for full instructions.
abstract class Store {
  factory Store.create() {
    final supabaseUrl = Platform.environment['SUPABASE_URL'];
    final supabaseKey = Platform.environment['SUPABASE_KEY'];
    if (supabaseUrl != null &&
        supabaseKey != null &&
        supabaseUrl.isNotEmpty &&
        supabaseKey.isNotEmpty) {
      print('[store] Using Supabase url=$supabaseUrl');
      return SupabaseStore(url: supabaseUrl, key: supabaseKey);
    }

    final projectId = Platform.environment['FIREBASE_PROJECT_ID'];
    final apiKey = Platform.environment['FIREBASE_API_KEY'];
    if (projectId != null && apiKey != null && projectId.isNotEmpty) {
      print('[store] Using Firestore project=$projectId');
      return FirestoreStore(projectId: projectId, apiKey: apiKey);
    }
    print('[store] Using in-memory store (no FIREBASE_PROJECT_ID set).');
    return MemoryStore();
  }

  // RSVPs
  Future<List<Rsvp>> listRsvps();
  Future<Rsvp> upsertRsvp(Map<String, dynamic> data);

  // Wishes
  Future<List<Wish>> listWishes();
  Future<Wish> addWish(Map<String, dynamic> data);

  // Guests
  Future<List<Guest>> listGuests();
  Future<Guest> addGuest(Map<String, dynamic> data);
  Future<void> deleteGuest(String id);
  Future<Guest?> guestBySlug(String slug);
}

const _uuid = Uuid();

String slugify(String name) => name
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
    .replaceAll(RegExp(r'\s+'), '-')
    .replaceAll(RegExp(r'-+'), '-')
    .replaceAll(RegExp(r'^-|-$'), '');

class MemoryStore implements Store {
  final List<Rsvp> _rsvps = [];
  final List<Wish> _wishes = [
    Wish(
      id: 'seed-1',
      name: 'Aunt Meera',
      message:
          'May your journey together be filled with endless love and laughter!',
      createdAt: DateTime.now().toIso8601String(),
    ),
    Wish(
      id: 'seed-2',
      name: 'Rahul',
      message: "So happy for you both. Can't wait to dance at the reception!",
      createdAt: DateTime.now().toIso8601String(),
    ),
  ];
  final List<Guest> _guests = [
    Guest(
      id: 'g-1',
      name: 'Rahul Sharma',
      slug: 'rahul-sharma',
      phone: '+919000000001',
      notes: '',
      createdAt: DateTime.now().toIso8601String(),
    ),
    Guest(
      id: 'g-2',
      name: 'Aunt Meera',
      slug: 'aunt-meera',
      phone: '+919000000002',
      notes: '',
      createdAt: DateTime.now().toIso8601String(),
    ),
    Guest(
      id: 'g-3',
      name: 'The Kapoor Family',
      slug: 'kapoor-family',
      phone: '+919000000003',
      notes: '',
      createdAt: DateTime.now().toIso8601String(),
    ),
  ];

  @override
  Future<List<Rsvp>> listRsvps() async =>
      List<Rsvp>.from(_rsvps)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<Rsvp> upsertRsvp(Map<String, dynamic> data) async {
    final phone = (data['phone'] as String).trim();
    final existingIdx = _rsvps.indexWhere((r) => r.phone == phone);
    final rsvp = Rsvp(
      id: existingIdx >= 0 ? _rsvps[existingIdx].id : _uuid.v4(),
      name: data['name'] as String,
      phone: phone,
      attending: data['attending'] as bool,
      guests: (data['guests'] as num?)?.toInt() ?? (data['attending'] == true ? 1 : 0),
      message: data['message'] as String? ?? '',
      guestSlug: data['guestSlug'] as String? ?? '',
      createdAt: existingIdx >= 0
          ? _rsvps[existingIdx].createdAt
          : DateTime.now().toIso8601String(),
    );
    if (existingIdx >= 0) {
      _rsvps[existingIdx] = rsvp;
    } else {
      _rsvps.add(rsvp);
    }
    return rsvp;
  }

  @override
  Future<List<Wish>> listWishes() async =>
      List<Wish>.from(_wishes)..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<Wish> addWish(Map<String, dynamic> data) async {
    final w = Wish(
      id: _uuid.v4(),
      name: (data['name'] as String).trim(),
      message: (data['message'] as String).trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    _wishes.insert(0, w);
    return w;
  }

  @override
  Future<List<Guest>> listGuests() async => List<Guest>.from(_guests);

  @override
  Future<Guest> addGuest(Map<String, dynamic> data) async {
    final name = (data['name'] as String).trim();
    final slug =
        '${slugify(name)}-${_uuid.v4().substring(0, 4)}';
    final g = Guest(
      id: _uuid.v4(),
      name: name,
      slug: slug,
      phone: (data['phone'] as String?)?.trim() ?? '',
      notes: (data['notes'] as String?)?.trim() ?? '',
      createdAt: DateTime.now().toIso8601String(),
    );
    _guests.insert(0, g);
    return g;
  }

  @override
  Future<void> deleteGuest(String id) async {
    _guests.removeWhere((g) => g.id == id);
  }

  @override
  Future<Guest?> guestBySlug(String slug) async {
    try {
      return _guests.firstWhere((g) => g.slug == slug);
    } catch (_) {
      return null;
    }
  }
}
