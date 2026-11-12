import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/staff_repository.dart';
import '../data/repositories/settings_repository.dart';

class AuthProvider extends ChangeNotifier {
  final StaffRepository _staffRepository;
  final SettingsRepository _settingsRepository;

  User? _currentUser;
  UserRole? _previewRole;
  String _latestRecoveryCode = '';
  Timer? _inactivityTimer;

  AuthProvider({
    required StaffRepository staffRepository,
    required SettingsRepository settingsRepository,
  })  : _staffRepository = staffRepository,
        _settingsRepository = settingsRepository;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isRealOwner => _currentUser?.role == UserRole.owner;
  UserRole? get effectiveRole => _previewRole ?? _currentUser?.role;
  bool get isOwner => effectiveRole == UserRole.owner;
  bool get isStaff => effectiveRole == UserRole.staff;
  String get latestRecoveryCode => _latestRecoveryCode;
  bool get isFirstRunCompleted => _settingsRepository.getSettings().isFirstRunCompleted;

  bool hasRole(UserRole role) {
    final activeRole = effectiveRole;
    if (activeRole == null) return false;
    if (activeRole == UserRole.owner) return true; // Owner has all permissions
    return activeRole == role;
  }

  /// Initial setup for owner on first run
  Future<String> setupOwner({
    required String name,
    required String username,
    required String password,
    required String phone,
  }) async {
    final recoveryCode = _settingsRepository.generateRecoveryCode();
    final owner = User(
      id: 'owner-1',
      name: name.trim(),
      username: username.trim().toLowerCase(),
      password: password,
      role: UserRole.owner,
      phone: phone.trim(),
      isActive: true,
      recoveryCode: recoveryCode,
    );

    _staffRepository.addUser(owner);
    _currentUser = owner;
    _latestRecoveryCode = recoveryCode;

    final currentSettings = _settingsRepository.getSettings();
    _settingsRepository.updateSettings(
      currentSettings.copyWith(
        isFirstRunCompleted: true,
        phone: phone.trim().isNotEmpty ? phone.trim() : currentSettings.phone,
      ),
    );

    _resetInactivityTimer();
    notifyListeners();
    return recoveryCode;
  }

  /// Authenticate with username and password
  bool login(String username, String password) {
    final cleanUsername = username.trim().toLowerCase();
    final user = _staffRepository.getUserByUsername(cleanUsername);

    if (user != null && user.password == password && user.isActive) {
      _currentUser = user;
      _previewRole = null;
      _resetInactivityTimer();
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update password for logged-in user
  bool changePassword(String currentPassword, String newPassword) {
    if (_currentUser == null || _currentUser!.password != currentPassword) {
      return false;
    }
    final updated = _currentUser!.copyWith(password: newPassword);
    _staffRepository.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
    return true;
  }

  /// Reset password using recovery code
  /// Owner gets a NEW recovery code after every reset
  String? resetPasswordWithRecoveryCode({
    required String username,
    required String recoveryCode,
    required String newPassword,
  }) {
    final cleanUsername = username.trim().toLowerCase();
    final user = _staffRepository.getUserByUsername(cleanUsername);

    if (user != null &&
        user.isOwner &&
        user.recoveryCode.toUpperCase().replaceAll('-', '') ==
            recoveryCode.trim().toUpperCase().replaceAll('-', '')) {
      final newCode = _settingsRepository.generateRecoveryCode();
      final updatedUser = user.copyWith(
        password: newPassword,
        recoveryCode: newCode,
      );
      _staffRepository.updateUser(updatedUser);
      _latestRecoveryCode = newCode;
      notifyListeners();
      return newCode;
    }
    return null;
  }

  /// Change role dynamically (Developer Tools for testing)
  void switchRole(UserRole newRole) {
    if (isRealOwner) {
      _previewRole = newRole;
      notifyListeners();
    }
  }

  VoidCallback? onAutoLogout;

  /// Reset user inactivity timer
  void userActivityDetected() {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    final minutes = _settingsRepository.getSettings().autoLogoutMinutes;
    if (minutes > 0 && _currentUser != null) {
      _inactivityTimer = Timer(Duration(minutes: minutes), () {
        logout();
        onAutoLogout?.call();
      });
    }
  }

  void logout() {
    _currentUser = null;
    _previewRole = null;
    _inactivityTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }
}

