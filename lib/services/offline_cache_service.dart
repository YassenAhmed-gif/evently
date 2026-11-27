import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';

/// Offline cache using Hive.
/// Stores events as plain maps in a 'events' box.
class OfflineCacheService {
  static const _boxName = 'events';

  /// Open the Hive box. Call once at app startup.
  static Future<void> init() async {
    await Hive.openBox<Map>(_boxName);
  }

  Box<Map> get _box => Hive.box<Map>(_boxName);

  // ── Read ────────────────────────────────────────────────

  List<EventModel> getAll() {
    return _box.values
        .map((m) => EventModel.fromMap(m))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── Write ───────────────────────────────────────────────

  Future<void> putAll(List<EventModel> events) async {
    final entries = {for (final e in events) e.id: e.toMap()};
    await _box.putAll(entries);
  }

  Future<void> put(EventModel event) async {
    await _box.put(event.id, event.toMap());
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
