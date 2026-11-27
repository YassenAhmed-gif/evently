import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../services/offline_cache_service.dart';

/// Manages the events list, bridging Firestore (online) and Hive (offline).
///
/// Strategy:
///  - Online : subscribes to Firestore real-time stream and mirrors to Hive.
///  - Offline: reads from Hive. Pending mutations are applied locally and
///             replayed to Firestore once connectivity is restored.
class EventProvider extends ChangeNotifier {
  final EventService _svc;
  final OfflineCacheService _cache;
  final _uuid = const Uuid();

  EventProvider({
    EventService? service,
    OfflineCacheService? cache,
  })  : _svc = service ?? EventService(),
        _cache = cache ?? OfflineCacheService();

  // ── State ────────────────────────────────────────────────

  List<EventModel> _events = [];
  EventCategory? _selected;
  bool _isOnline = true;
  bool _isLoading = false;
  String? _userId;

  StreamSubscription<List<EventModel>>? _firestoreSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  List<EventModel> get events {
    final base = _selected == null
        ? _events
        : _events.where((e) => e.category == _selected).toList();
    return List.unmodifiable(base);
  }

  List<EventModel> get favorites =>
      _events.where((e) => e.isFavorite).toList();

  EventCategory? get selected => _selected;
  bool get isOnline => _isOnline;
  bool get isLoading => _isLoading;

  // ── Initialisation ───────────────────────────────────────

  /// Call when a user signs in. Starts Firestore stream + connectivity watcher.
  void init(String userId) {
    if (_userId == userId) return; // already initialised for this user
    _userId = userId;

    // Load cached events immediately so the UI isn't blank
    _events = _cache.getAll();
    notifyListeners();

    _startConnectivityWatch();
    _subscribeFirestore();
  }

  /// Call on sign-out. Cleans up streams and clears state.
  void reset() {
    _firestoreSub?.cancel();
    _connectivitySub?.cancel();
    _events = [];
    _selected = null;
    _userId = null;
    notifyListeners();
  }

  void _startConnectivityWatch() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && !_isOnline) {
        _isOnline = true;
        _subscribeFirestore(); // reconnect stream
      } else if (!online && _isOnline) {
        _isOnline = false;
        notifyListeners();
      }
    });
  }

  void _subscribeFirestore() {
    if (_userId == null) return;
    _firestoreSub?.cancel();
    _firestoreSub = _svc.watchEvents(_userId!).listen((list) async {
      _events = list;
      _isLoading = false;
      notifyListeners();
      // Mirror to cache
      await _cache.putAll(list);
    });
  }

  // ── Category filter ──────────────────────────────────────

  void selectCategory(EventCategory? c) {
    _selected = c;
    notifyListeners();
  }

  // ── CRUD ─────────────────────────────────────────────────

  Future<void> addEvent({
    required String title,
    required String description,
    required EventCategory category,
    required DateTime date,
    TimeOfDay? time,
    String location = '',
  }) async {
    final event = EventModel(
      id: _uuid.v4(),
      userId: _userId ?? '',
      title: title,
      description: description,
      category: category,
      date: date,
      time: time,
      location: location,
    );

    // Optimistic local update
    _events.insert(0, event);
    notifyListeners();
    await _cache.put(event);

    // Persist to Firestore (or queue for later when offline)
    try {
      await _svc.addEvent(event);
    } catch (_) {
      // Will be replayed by Firestore offline SDK when back online
    }
  }

  Future<void> updateEvent(EventModel updated) async {
    final idx = _events.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;

    _events[idx] = updated;
    notifyListeners();
    await _cache.put(updated);

    try {
      await _svc.updateEvent(updated);
    } catch (_) {}
  }

  Future<void> deleteEvent(String id) async {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
    await _cache.delete(id);

    try {
      await _svc.deleteEvent(id);
    } catch (_) {}
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _events.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final updated = _events[idx].copyWith(isFavorite: !_events[idx].isFavorite);
    _events[idx] = updated;
    notifyListeners();
    await _cache.put(updated);

    try {
      await _svc.setFavorite(id, updated.isFavorite);
    } catch (_) {}
  }

  @override
  void dispose() {
    _firestoreSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
