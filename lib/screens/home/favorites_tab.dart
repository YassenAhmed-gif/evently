import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/event_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_style.dart';
import '../../widgets/event_card.dart';

class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final all = context.watch<EventProvider>().favorites;
    final list = all
        .where((e) =>
            e.title.toLowerCase().contains(_query.toLowerCase()) ||
            e.location.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppStyle.pagePadding, 16, AppStyle.pagePadding, 8),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColor.primary, size: 22),
                const SizedBox(width: 8),
                Text(l.favorites,
                    style: AppStyle.title20
                        .copyWith(color: AppColor.primary)),
                const Spacer(),
                Text('${all.length} event${all.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                        color: AppColor.grey, fontSize: 13)),
              ],
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppStyle.pagePadding, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.searchEvent,
                prefixIcon: const Icon(Icons.search, color: AppColor.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColor.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColor.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColor.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // List or empty state
          Expanded(
            child: list.isEmpty
                ? _EmptyFavorites(hasQuery: _query.isNotEmpty)
                : RefreshIndicator(
                    onRefresh: () async =>
                        await Future.delayed(const Duration(seconds: 1)),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          AppStyle.pagePadding,
                          8,
                          AppStyle.pagePadding,
                          100),
                      itemCount: list.length,
                      itemBuilder: (_, i) => EventCard(event: list[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final bool hasQuery;
  const _EmptyFavorites({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.favorite_border,
            size: 72,
            color: AppColor.primary.withValues(alpha: .3),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'No favorites match your search' : 'No favorites yet',
            style: const TextStyle(
                color: AppColor.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          if (!hasQuery) ...[
            const SizedBox(height: 8),
            const Text(
              'Tap the ♡ on any event to save it here',
              style: TextStyle(color: AppColor.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
