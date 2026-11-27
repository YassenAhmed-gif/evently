import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum EventCategory {
  sport(Icons.directions_bike, Color(0xFFEE5A5A)),
  birthday(Icons.cake_outlined, Color(0xFFE9A53B)),
  meeting(Icons.groups_outlined, Color(0xFF6C63FF)),
  gaming(Icons.sports_esports_outlined, Color(0xFF3CB371)),
  workshop(Icons.build_outlined, Color(0xFF2D9CDB)),
  bookClub(Icons.menu_book_outlined, Color(0xFF1C1C1C)),
  exhibition(Icons.museum_outlined, Color(0xFFB05CC6)),
  holiday(Icons.beach_access_outlined, Color(0xFF00A6A6)),
  eating(Icons.restaurant_outlined, Color(0xFFFF8A3D));

  final IconData icon;
  final Color color;
  const EventCategory(this.icon, this.color);

  String label(AppLocalizations l) {
    switch (this) {
      case EventCategory.sport:
        return l.sport;
      case EventCategory.birthday:
        return l.birthday;
      case EventCategory.meeting:
        return l.meeting;
      case EventCategory.gaming:
        return l.gaming;
      case EventCategory.workshop:
        return l.workshop;
      case EventCategory.bookClub:
        return l.bookClub;
      case EventCategory.exhibition:
        return l.exhibition;
      case EventCategory.holiday:
        return l.holiday;
      case EventCategory.eating:
        return l.eating;
    }
  }
}

class EventModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime date;
  final TimeOfDay? time;
  final String location;
  final bool isFavorite;

  const EventModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    this.time,
    this.location = '',
    this.isFavorite = false,
  });

  /// Create from Firestore document
  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      title: d['title'] as String? ?? '',
      description: d['description'] as String? ?? '',
      category: EventCategory.values.firstWhere(
        (c) => c.name == (d['category'] as String? ?? ''),
        orElse: () => EventCategory.meeting,
      ),
      date: (d['date'] as Timestamp).toDate(),
      time: d['timeHour'] != null
          ? TimeOfDay(
              hour: d['timeHour'] as int,
              minute: d['timeMinute'] as int,
            )
          : null,
      location: d['location'] as String? ?? '',
      isFavorite: d['isFavorite'] as bool? ?? false,
    );
  }

  /// Create from local Hive map (offline cache)
  factory EventModel.fromMap(Map<dynamic, dynamic> m) {
    return EventModel(
      id: m['id'] as String,
      userId: m['userId'] as String? ?? '',
      title: m['title'] as String,
      description: m['description'] as String,
      category: EventCategory.values.firstWhere(
        (c) => c.name == (m['category'] as String),
        orElse: () => EventCategory.meeting,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
      time: m['timeHour'] != null
          ? TimeOfDay(
              hour: m['timeHour'] as int,
              minute: m['timeMinute'] as int,
            )
          : null,
      location: m['location'] as String? ?? '',
      isFavorite: m['isFavorite'] as bool? ?? false,
    );
  }

  /// Serialise to Firestore
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'description': description,
        'category': category.name,
        'date': Timestamp.fromDate(date),
        'timeHour': time?.hour,
        'timeMinute': time?.minute,
        'location': location,
        'isFavorite': isFavorite,
      };

  /// Serialise to Hive map (offline cache)
  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'category': category.name,
        'date': date.millisecondsSinceEpoch,
        'timeHour': time?.hour,
        'timeMinute': time?.minute,
        'location': location,
        'isFavorite': isFavorite,
      };

  EventModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? date,
    TimeOfDay? time,
    String? location,
    bool? isFavorite,
  }) =>
      EventModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        date: date ?? this.date,
        time: time ?? this.time,
        location: location ?? this.location,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

