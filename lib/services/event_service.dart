import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

/// Firestore CRUD service for events.
/// Collection structure: `events/{eventId}`
class EventService {
  static final _col = FirebaseFirestore.instance.collection('events');

  /// Stream of all events belonging to [userId], ordered by date descending.
  Stream<List<EventModel>> watchEvents(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(EventModel.fromFirestore).toList());
  }

  /// Add a new event document.
  Future<void> addEvent(EventModel event) async {
    await _col.doc(event.id).set(event.toFirestore());
  }

  /// Update an existing event document.
  Future<void> updateEvent(EventModel event) async {
    await _col.doc(event.id).update(event.toFirestore());
  }

  /// Delete an event document.
  Future<void> deleteEvent(String id) async {
    await _col.doc(id).delete();
  }

  /// Toggle favorite field for a single event.
  Future<void> setFavorite(String id, bool isFavorite) async {
    await _col.doc(id).update({'isFavorite': isFavorite});
  }

  /// Fetch all events for [userId] once (used as offline seed).
  Future<List<EventModel>> fetchOnce(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs.map(EventModel.fromFirestore).toList();
  }
}
