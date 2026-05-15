import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginViewModel extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _errorMessage;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);

  // Getters for the View to read the state
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabase.auth.currentSession != null;
  bool get isLockedOut =>
      _lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!);

  Duration get lockoutRemaining {
    if (!isLockedOut || _lockoutUntil == null) return Duration.zero;
    return _lockoutUntil!.difference(DateTime.now());
  }

  // The logic triggered by the View's "Sign In" button
  Future<bool> login(String email, String password) async {
    if (isLockedOut) {
      final remaining = lockoutRemaining;
      _errorMessage =
          'Too many failed attempts. Try again in ${remaining.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(remaining.inSeconds.remainder(60)).toString().padLeft(2, '0')}';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Tells the UI to show a loading spinner

    bool success = false;
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      success = response.session != null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
    }

    if (!success) {
      _failedAttempts += 1;
      if (_failedAttempts >= maxFailedAttempts) {
        _lockoutUntil = DateTime.now().add(lockoutDuration);
        _errorMessage = 'Too many failed attempts. Locked for 5 minutes.';
      }
    } else {
      _failedAttempts = 0;
      _lockoutUntil = null;
      _errorMessage = null;
    }

    _isLoading = false;
    notifyListeners(); // Tells the UI to stop loading

    return success;
  }

  void signOut() async {
    await _supabase.auth.signOut();
    notifyListeners();
  }
}
