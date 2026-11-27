import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_color.dart';
import '../../utils/app_images.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_style.dart';
import '../../widgets/custom_text_field.dart';
import 'validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _rePassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _rePassword.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
        _name.text, _email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (_) => false);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error!),
          backgroundColor: AppColor.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isLoading = context.select<AuthProvider, bool>((a) => a.isLoading);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(l.createAccount)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyle.pagePadding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const AppImage(AppImages.logo,
                      width: 90, height: 90, fallback: Icons.celebration),
                  Text(l.appName,
                      style:
                          AppStyle.title24.copyWith(color: AppColor.primary)),
                  const SizedBox(height: 24),
                  CustomTextField(
                      controller: _name,
                      hint: l.name,
                      icon: Icons.person_outline,
                      validator: (v) => Validators.required(v, l)),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _email,
                      hint: l.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => Validators.email(v, l)),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _password,
                      hint: l.password,
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: (v) => Validators.password(v, l)),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _rePassword,
                    hint: l.rePassword,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) => v != _password.text
                        ? l.passwordsNotMatch
                        : Validators.required(v, l),
                  ),
                  const SizedBox(height: 24),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _register, child: Text(l.createAccount)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.alreadyHaveAccount),
                      TextButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        child: Text(l.login,
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                decoration: TextDecoration.underline)),
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
