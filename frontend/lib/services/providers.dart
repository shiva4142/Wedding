import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/guest.dart';
import '../models/wish.dart';
import 'api_service.dart';

/// Live attending count (polls backend every 8s).
final attendingCountProvider = StreamProvider<int>((ref) {
  final api = ref.watch(apiServiceProvider);
  late StreamController<int> controller;
  Timer? timer;

  Future<void> tick() async {
    try {
      final c = await api.attendingCount();
      if (!controller.isClosed) controller.add(c);
    } catch (_) {}
  }

  controller = StreamController<int>(
    onListen: () {
      tick();
      timer = Timer.periodic(const Duration(seconds: 8), (_) => tick());
    },
    onCancel: () {
      timer?.cancel();
    },
  );
  return controller.stream;
});

/// Live wishes feed (polls every 6s).
final wishesProvider = StreamProvider<List<Wish>>((ref) {
  final api = ref.watch(apiServiceProvider);
  late StreamController<List<Wish>> controller;
  Timer? timer;

  Future<void> tick() async {
    try {
      final list = await api.listWishes();
      if (!controller.isClosed) controller.add(list);
    } catch (_) {}
  }

  controller = StreamController<List<Wish>>(
    onListen: () {
      tick();
      timer = Timer.periodic(const Duration(seconds: 6), (_) => tick());
    },
    onCancel: () => timer?.cancel(),
  );
  return controller.stream;
});

final guestProvider =
    FutureProvider.family<Guest?, String?>((ref, slug) async {
  if (slug == null || slug.isEmpty) return null;
  final api = ref.read(apiServiceProvider);
  return api.guestBySlug(slug);
});

/// Music on/off
final musicOnProvider = StateProvider<bool>((_) => false);

/// Admin login state
final adminTokenProvider =
    StateNotifierProvider<AdminTokenController, String?>(
  (ref) => AdminTokenController(ref.read(apiServiceProvider)),
);

class AdminTokenController extends StateNotifier<String?> {
  AdminTokenController(this._api) : super(null) {
    _hydrate();
  }
  final ApiService _api;

  Future<void> _hydrate() async {
    final t = await _api.loadToken();
    state = t;
  }

  Future<void> login(String email, String password) async {
    state = await _api.adminLogin(email, password);
  }

  Future<void> logout() async {
    await _api.setToken(null);
    state = null;
  }
}
