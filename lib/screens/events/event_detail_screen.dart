import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currentUid =
        context.read<AuthProvider>().currentUser?.uid ?? '';
    final isOwner = event.userId == currentUid;
    final eventWatched = context.select<EventProvider, EventModel?>(
      (p) => p.events.cast<EventModel?>().firstWhere(
            (e) => e?.id == event.id,
            orElse: () => null,
          ),
    );
    final live = eventWatched ?? event;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: live.category.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                live.category.label(l),
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w400),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      live.category.color,
                      live.category.color.withValues(alpha: .6)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(live.category.icon,
                      size: 110, color: Colors.white.withValues(alpha: .4)),
                ),
              ),
            ),
            actions: [
              // Favorite toggle
              Consumer<EventProvider>(
                builder: (_, prov, __) {
                  final ev = prov.events.cast<EventModel?>().firstWhere(
                        (e) => e?.id == live.id,
                        orElse: () => null,
                      ) ??
                      live;
                  return IconButton(
                    tooltip: ev.isFavorite ? 'Remove favorite' : 'Add favorite',
                    icon: Icon(
                      ev.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () =>
                        context.read<EventProvider>().toggleFavorite(ev.id),
                  );
                },
              ),
              if (isOwner) ...[
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.editEvent,
                    arguments: live,
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon:
                      const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _confirmDelete(context, live),
                ),
              ],
            ],
          ),

          // ── Detail Body ───────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(AppStyle.pagePadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(live.title,
                    style: AppStyle.title24
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),

                // Info rows
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  color: live.category.color,
                  label: 'Date',
                  value: DateFormat.yMMMMEEEEd(l.localeName).format(live.date),
                ),
                if (live.time != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time,
                    color: live.category.color,
                    label: 'Time',
                    value: live.time!.format(context),
                  ),
                ],
                if (live.location.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    color: live.category.color,
                    label: 'Location',
                    value: live.location,
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Description
                const Text('About this event', style: AppStyle.title18),
                const SizedBox(height: 10),
                Text(live.description,
                    style: AppStyle.body16
                        .copyWith(height: 1.6, color: AppColor.grey)),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EventModel ev) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Delete "${ev.title}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColor.red),
            onPressed: () {
              context.read<EventProvider>().deleteEvent(ev.id);
              Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == AppRoutes.main);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppStyle.body14
                      .copyWith(color: AppColor.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: AppStyle.body16.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
