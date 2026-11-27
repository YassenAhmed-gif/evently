import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Exposes the current Firebase user's display name and email.
class ProfileProvider extends ChangeNotifier {
  User? get _user => FirebaseAuth.instance.currentUser;

  String get name => _user?.displayName ?? 'User';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;

  void refresh() => notifyListeners();

  Future<void> updateProfile({String? name}) async {
    await _user?.updateDisplayName(name);
    notifyListeners();
  }
}
