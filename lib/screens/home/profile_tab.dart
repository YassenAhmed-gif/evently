import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/nav_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../widgets/options_sheet.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final profile = context.watch<ProfileProvider>();
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final eventCount =
        context.select<EventProvider, int>((p) => p.events.length);
    final favCount =
        context.select<EventProvider, int>((p) => p.favorites.length);

    return Column(
      children: [
        // ── Profile Header ───────────────────────────────────
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
              AppStyle.pagePadding,
              MediaQuery.of(context).padding.top + 20,
              AppStyle.pagePadding,
              28),
          decoration: const BoxDecoration(
            color: AppColor.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: profile.photoUrl != null
                    ? Image.network(profile.photoUrl!, fit: BoxFit.cover)
                    : const AppImage(AppImages.avatar,
                        fallback: Icons.person,
                        fallbackColor: AppColor.primary),
              ),
              const SizedBox(height: 14),
              Text(profile.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(profile.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 20),
              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatChip(
                      label: 'Events',
                      value: eventCount,
                      icon: Icons.event_outlined),
                  const SizedBox(width: 16),
                  _StatChip(
                      label: 'Saved',
                      value: favCount,
                      icon: Icons.favorite_border),
                ],
              ),
            ],
          ),
        ),

        // ── Settings ─────────────────────────────────────────
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppStyle.pagePadding),
            children: [
              const SizedBox(height: 8),
              const _SectionHeader(label: 'Preferences'),
              const SizedBox(height: 10),
              _SettingTile(
                icon: Icons.language_outlined,
                title: l.language,
                value: locale.isArabic ? l.arabic : l.english,
                onTap: () => showOptionsSheet<String>(
                  context: context,
                  title: l.selectLanguage,
                  selected: locale.locale.languageCode,
                  options: [
                    SheetOption('en', l.english, Icons.language),
                    SheetOption('ar', l.arabic, Icons.translate),
                  ],
                  onSelected: (v) =>
                      context.read<LocaleProvider>().setLocale(Locale(v)),
                ),
              ),
              const SizedBox(height: 10),
              _SettingTile(
                icon: theme.isDark
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: l.theme,
                value: theme.isDark ? l.dark : l.light,
                onTap: () => showOptionsSheet<ThemeMode>(
                  context: context,
                  title: l.selectTheme,
                  selected: theme.mode,
                  options: [
                    SheetOption(ThemeMode.light, l.light, Icons.light_mode),
                    SheetOption(ThemeMode.dark, l.dark, Icons.dark_mode),
                  ],
                  onSelected: (v) =>
                      context.read<ThemeProvider>().setMode(v),
                ),
              ),
              const SizedBox(height: 28),
              const _SectionHeader(label: 'Account'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.red,
                    minimumSize: const Size.fromHeight(52)),
                onPressed: () async {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    context.read<NavProvider>().setIndex(0);
                    Navigator.pushNamedAndRemoveUntil(
                        context, AppRoutes.login, (_) => false);
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l.logout),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text('$value',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(),
        style: const TextStyle(
            color: AppColor.grey,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2));
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColor.primary, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 11, color: AppColor.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: AppStyle.body16
                          .copyWith(color: AppColor.primary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColor.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
