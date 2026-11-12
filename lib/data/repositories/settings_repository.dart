import 'dart:math';
import '../models/settings_model.dart';

abstract class SettingsRepository {
  StoreSettings getSettings();
  void updateSettings(StoreSettings settings);
  String generateRecoveryCode();
}

class MockSettingsRepository implements SettingsRepository {
  StoreSettings _settings = const StoreSettings(
    isFirstRunCompleted: false, // App starts with First-run setup!
  );

  @override
  StoreSettings getSettings() => _settings;

  @override
  void updateSettings(StoreSettings settings) {
    _settings = settings;
  }

  @override
  String generateRecoveryCode() {
    final random = Random();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final part1 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    final part2 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    final part3 = List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
    return '$part1-$part2-$part3';
  }
}

