import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/event_provider.dart';
import '../../providers/profile_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_style.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/event_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prov = context.watch<EventProvider>();
    final profile = context.watch<ProfileProvider>();
    final isOnline = prov.isOnline;

    var events = prov.events;
    if (_query.isNotEmpty) {
      events = events
          .where((e) =>
              e.title.toLowerCase().contains(_query.toLowerCase()) ||
              e.location.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              AppStyle.pagePadding,
              MediaQuery.of(context).padding.top + 12,
              AppStyle.pagePadding,
              16),
          decoration: const BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.welcomeBack,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        Text(profile.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  // Online / Offline indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? Colors.white.withValues(alpha: .2)
                          : AppColor.red.withValues(alpha: .8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOnline ? Icons.wifi : Icons.wifi_off,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style:
                      const TextStyle(color: AppColor.black, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l.searchEvent,
                    hintStyle:
                        const TextStyle(color: AppColor.grey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColor.grey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CategoryChips.home(),
            ],
          ),
        ),

        // ── Event List ───────────────────────────────────────
        Expanded(
          child: prov.isLoading
              ? const Center(child: CircularProgressIndicator())
              : events.isEmpty
                  ? _EmptyState(query: _query)
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Firestore stream auto-refreshes; just wait briefly
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            AppStyle.pagePadding,
                            16,
                            AppStyle.pagePadding,
                            100),
                        itemCount: events.length,
                        itemBuilder: (_, i) => EventCard(event: events[i]),
                      ),
                    ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            query.isNotEmpty ? Icons.search_off : Icons.event_busy_outlined,
            size: 64,
            color: AppColor.primary.withValues(alpha: .4),
          ),
          const SizedBox(height: 16),
          Text(
            query.isNotEmpty ? 'No results for "$query"' : 'No events yet',
            style: const TextStyle(
                color: AppColor.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Tap + to create your first event',
              style: TextStyle(color: AppColor.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
