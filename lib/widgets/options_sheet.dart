import 'package:flutter/material.dart';
import '../utils/app_color.dart';
import '../utils/app_style.dart';

class SheetOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const SheetOption(this.value, this.label, [this.icon]);
}

/// Reusable bottom sheet used for language and theme selection.
Future<void> showOptionsSheet<T>({
  required BuildContext context,
  required String title,
  required List<SheetOption<T>> options,
  required T selected,
  required ValueChanged<T> onSelected,
}) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppStyle.title20),
            const SizedBox(height: 12),
            for (final o in options)
              _OptionTile<T>(
                option: o,
                isSelected: o.value == selected,
                onTap: () {
                  onSelected(o.value);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

class _OptionTile<T> extends StatelessWidget {
  final SheetOption<T> option;
  final bool isSelected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.option, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColor.primary.withValues(alpha: .1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isSelected ? AppColor.primary : AppColor.lightGrey),
      ),
      child: ListTile(
        onTap: onTap,
        leading: option.icon == null
            ? null
            : Icon(option.icon, color: AppColor.primary),
        title: Text(option.label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColor.primary : null)),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppColor.primary)
            : null,
      ),
    );
  }
}
