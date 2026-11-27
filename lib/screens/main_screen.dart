import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/nav_provider.dart';
import '../utils/app_color.dart';
import '../utils/app_routes.dart';
import 'home/favorites_tab.dart';
import 'home/home_tab.dart';
import 'home/map_tab.dart';
import 'home/profile_tab.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nav = context.watch<NavProvider>();

    const tabs = [HomeTab(), MapTab(), FavoritesTab(), ProfileTab()];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: nav.index, children: tabs),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createEvent),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColor.primary,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: l.home,
                  index: 0),
              _NavItem(
                  icon: Icons.location_on_outlined,
                  activeIcon: Icons.location_on,
                  label: l.map,
                  index: 1),
              const SizedBox(width: 56), // space for the FAB notch
              _NavItem(
                  icon: Icons.favorite_border,
                  activeIcon: Icons.favorite,
                  label: l.favorites,
                  index: 2),
              _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: l.profile,
                  index: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final selected = context.select<NavProvider, bool>((n) => n.index == index);
    final color = selected ? Colors.white : Colors.white70;

    return InkWell(
      onTap: () => context.read<NavProvider>().setIndex(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : icon, color: color),
            Text(label, style: TextStyle(color: color, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
