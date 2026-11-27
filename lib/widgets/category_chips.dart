import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import '../utils/app_color.dart';

/// Horizontal category filter. Used on the home header (onHeader: true)
/// and on the create-event screen (selection callback mode).
class CategoryChips extends StatelessWidget {
  final bool onHeader;
  final bool showAll;
  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelect;

  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelect,
    this.onHeader = false,
    this.showAll = true,
  });

  /// Convenience constructor bound to EventProvider.
  static Widget home() => Builder(builder: (context) {
        final p = context.watch<EventProvider>();
        return CategoryChips(
          onHeader: true,
          selected: p.selected,
          onSelect: p.selectCategory,
        );
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = <EventCategory?>[
      if (showAll) null,
      ...EventCategory.values,
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = items[i];
          final isSel = c == selected;
          final fg = onHeader
              ? (isSel ? AppColor.primary : Colors.white)
              : (isSel ? Colors.white : AppColor.primary);
          final bg = onHeader
              ? (isSel ? Colors.white : Colors.transparent)
              : (isSel ? AppColor.primary : Colors.transparent);
          final border = onHeader ? Colors.white : AppColor.primary;

          return GestureDetector(
            onTap: () => onSelect(c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Icon(c?.icon ?? Icons.explore_outlined,
                      size: 18, color: fg),
                  const SizedBox(width: 6),
                  Text(c == null ? l.all : c.label(l),
                      style: TextStyle(
                          color: fg, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
