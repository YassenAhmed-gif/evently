import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/option_toggle.dart';
import 'validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithEmail(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  Future<void> _loginWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
    } else if (auth.error != null) {
      _showError(auth.error!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColor.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyle.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const AppImage(AppImages.logo,
                      width: 100, height: 100, fallback: Icons.celebration),
                  Text(l.appName,
                      style:
                          AppStyle.title24.copyWith(color: AppColor.primary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _email,
                    hint: l.email,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => Validators.email(v, l),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _password,
                    hint: l.password,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => Validators.password(v, l),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.forgotPassword),
                      child: Text(l.forgotPassword,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              decoration: TextDecoration.underline)),
                    ),
                  ),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _login, child: Text(l.login)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.dontHaveAccount),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pushNamed(
                                context, AppRoutes.register),
                        child: Text(l.createAccount,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(l.or,
                          style: const TextStyle(color: AppColor.primary)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _loginWithGoogle,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: const BorderSide(color: AppColor.primary),
                      foregroundColor: AppColor.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppStyle.radius)),
                    ),
                    icon: const AppImage(AppImages.google,
                        width: 24, height: 24, fallback: Icons.g_mobiledata),
                    label: Text(l.loginWithGoogle),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        child: OptionToggle<String>(
                          label: '',
                          value: locale.locale.languageCode,
                          items: const [
                            ToggleItem('en', 'EN'),
                            ToggleItem('ar', 'AR')
                          ],
                          onChanged: (v) => context
                              .read<LocaleProvider>()
                              .setLocale(Locale(v)),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 100,
                        child: OptionToggle<ThemeMode>(
                          label: '',
                          value: theme.mode,
                          items: const [
                            ToggleItem(ThemeMode.light, '☀'),
                            ToggleItem(ThemeMode.dark, '☾'),
                          ],
                          onChanged: (v) =>
                              context.read<ThemeProvider>().setMode(v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
