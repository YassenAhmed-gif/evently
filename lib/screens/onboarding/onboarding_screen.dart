import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../widgets/option_toggle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  Future<void> _goLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _animate(int page) => _controller.animateToPage(page,
      duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pages = [
      (AppImages.onboarding1, l.onb1Title, l.onb1Body),
      (AppImages.onboarding2, l.onb2Title, l.onb2Body),
      (AppImages.onboarding3, l.onb3Title, l.onb3Body),
      (AppImages.onboarding4, l.onb4Title, l.onb4Body),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppStyle.pagePadding),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) {
                    final (img, title, body) = pages[i];
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          AppImage(img,
                              height: 280,
                              width: double.infinity,
                              fallback: Icons.celebration_outlined),
                          const SizedBox(height: 24),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(title,
                                style: AppStyle.title20
                                    .copyWith(color: AppColor.primary)),
                          ),
                          const SizedBox(height: 12),
                          Text(body, style: AppStyle.body16),
                          if (i == 0) ...[
                            const SizedBox(height: 24),
                            const _SettingsToggles(),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              if (_page == 0)
                ElevatedButton(onPressed: () => _animate(1), child: Text(l.letsStart))
              else
                Row(
                  children: [
                    _RoundButton(
                        icon: Icons.arrow_back,
                        onTap: () => _animate(_page - 1)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length - 1,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _page - 1 == i ? 18 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _page - 1 == i
                                  ? AppColor.primary
                                  : AppColor.lightGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _RoundButton(
                        icon: Icons.arrow_forward,
                        onTap: last ? _goLogin : () => _animate(_page + 1)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsToggles extends StatelessWidget {
  const _SettingsToggles();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();

    return Column(
      children: [
        OptionToggle<String>(
          label: l.language,
          value: locale.locale.languageCode,
          items: const [ToggleItem('en', 'EN'), ToggleItem('ar', 'AR')],
          onChanged: (v) => context.read<LocaleProvider>().setLocale(Locale(v)),
        ),
        const SizedBox(height: 16),
        OptionToggle<ThemeMode>(
          label: l.theme,
          value: theme.mode,
          items: const [
            ToggleItem(ThemeMode.light, '☀'),
            ToggleItem(ThemeMode.dark, '☾'),
          ],
          onChanged: (v) => context.read<ThemeProvider>().setMode(v),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.primary, width: 2)),
        child: Icon(icon, color: AppColor.primary),
      ),
    );
  }
}
