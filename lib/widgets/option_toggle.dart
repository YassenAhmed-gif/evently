import 'package:flutter/material.dart';
import '../utils/app_color.dart';

/// Small two-option switch used on onboarding (language / theme).
class OptionToggle<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<ToggleItem<T>> items;
  final ValueChanged<T> onChanged;

  const OptionToggle({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: AppColor.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500)),
        ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.primary, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: items.map((it) {
              final selected = it.value == value;
              return GestureDetector(
                onTap: () => onChanged(it.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColor.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(it.label,
                      style: TextStyle(
                          color: selected ? Colors.white : AppColor.primary,
                          fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ToggleItem<T> {
  final T value;
  final String label;
  const ToggleItem(this.value, this.label);
}
