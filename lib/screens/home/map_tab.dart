import 'package:flutter/material.dart';
import '../../utils/app_color.dart';
import '../../utils/app_style.dart';

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppStyle.pagePadding, 16, AppStyle.pagePadding, 8),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppColor.primary, size: 22),
                const SizedBox(width: 8),
                Text('Map',
                    style: AppStyle.title20
                        .copyWith(color: AppColor.primary)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withValues(alpha: .1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        size: 72,
                        color: AppColor.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Map View',
                      style: AppStyle.title24
                          .copyWith(color: AppColor.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Event locations will be displayed here.\nAdd google_maps_flutter to enable the map.',
                      textAlign: TextAlign.center,
                      style: AppStyle.body14.copyWith(
                          color: AppColor.grey, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColor.primary),
                        foregroundColor: AppColor.primary,
                        minimumSize: const Size(220, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppStyle.radius)),
                      ),
                      icon: const Icon(Icons.location_on_outlined),
                      label: const Text('Coming Soon'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
