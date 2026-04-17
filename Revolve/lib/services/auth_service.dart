import 'package:flutter/foundation.dart';

class AppUser {
  final String uid;
  final String name;
  final String email;

  AppUser({required this.uid, required this.name, required this.email});
}

class AuthService extends ChangeNotifier {
  // Minimal in-memory auth to satisfy your screens
  bool _isAuthenticated = true; // set true so Splash goes to /home
  bool get isAuthenticated => _isAuthenticated;

  // Simple role flag used by AdminDashboard
  bool _isAdminOrModerator = true; // set true to access /admin
  bool get isAdminOrModerator => _isAdminOrModerator;

  AppUser? _currentAppUser;
  AppUser? get currentAppUser => _currentAppUser;

  // For compatibility with your code (expects currentUser!.uid/email)
  AppUser? get currentUser => _currentAppUser;

  void bootstrap() {
    _currentAppUser = AppUser(
      uid: 'demo-user-001',
      name: 'Demo User',
      email: 'demo@citypulse.app',
    );
  }

  Future<String?> signIn(String email, String password) async {
    _isAuthenticated = true;
    notifyListeners();
    return null;
  }

  Future<String?> signUp(String name, String email, String password) async {
    _isAuthenticated = true;
    _currentAppUser = AppUser(uid: 'new-user-001', name: name, email: email);
    notifyListeners();
    return null;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Toggle role quickly (for testing)
  void setAdmin(bool isAdmin) {
    _isAdminOrModerator = isAdmin;
    notifyListeners();
  }
}
