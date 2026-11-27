import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../utils/app_color.dart';
import '../utils/app_routes.dart';
import '../utils/app_style.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    final currentUid = context.read<AuthProvider>().currentUser?.uid ?? '';
    final isOwner = event.userId == currentUid;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.eventDetail, arguments: event),
      onLongPress: isOwner ? () => _showOptions(context) : null,
      child: Container(
        height: 190,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppStyle.radius),
          boxShadow: [
            BoxShadow(
              color: event.category.color.withValues(alpha: .3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            colors: [event.category.color, event.category.color.withValues(alpha: .6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background icon watermark
            Center(
              child: Icon(event.category.icon,
                  size: 80, color: Colors.white.withValues(alpha: .25)),
            ),
            // Date badge (top-left)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Text(DateFormat('dd', l.localeName).format(event.date),
                        style: TextStyle(
                            color: event.category.color,
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    Text(DateFormat('MMM', l.localeName).format(event.date),
                        style: TextStyle(
                            color: event.category.color, fontSize: 11)),
                  ],
                ),
              ),
            ),
            // Owner badge (top-right)
            if (isOwner)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 12, color: event.category.color),
                      const SizedBox(width: 3),
                      Text('Mine',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: event.category.color)),
                    ],
                  ),
                ),
              ),
            // Bottom: title + favorite
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                    color: surface.withValues(alpha: .95),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.body14.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          if (event.location.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 11, color: AppColor.grey),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(event.location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle.caption12
                                          .copyWith(color: AppColor.grey)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () =>
                          context.read<EventProvider>().toggleFavorite(event.id),
                      icon: Icon(
                        event.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: event.isFavorite ? AppColor.red : AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColor.primary),
              title: const Text('Edit Event'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.editEvent,
                    arguments: event);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColor.red),
              title: const Text('Delete Event',
                  style: TextStyle(color: AppColor.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${event.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.red),
            onPressed: () {
              context.read<EventProvider>().deleteEvent(event.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
