import '../../l10n/app_localizations.dart';

class Validators {
  Validators._();

  static String? required(String? v, AppLocalizations l) =>
      (v == null || v.trim().isEmpty) ? l.fieldRequired : null;

  static String? email(String? v, AppLocalizations l) {
    if (v == null || v.trim().isEmpty) return l.fieldRequired;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : l.invalidEmail;
  }

  static String? password(String? v, AppLocalizations l) {
    if (v == null || v.isEmpty) return l.fieldRequired;
    return v.length < 6 ? l.passwordShort : null;
  }
}
