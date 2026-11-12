import '../models/user_model.dart';
import '../models/audit_model.dart';
import 'demo_data.dart';

abstract class StaffRepository {
  List<User> getStaffList();
  User? getUserById(String id);
  User? getUserByUsername(String username);
  void addUser(User user);
  void updateUser(User user);
  void deleteUser(String id);

  List<ActivityLog> getActivityLogs();
  void logActivity(ActivityLog log);

  void loadDemoData();
  void clearData();
}

class MockStaffRepository implements StaffRepository {
  final List<User> _users = [];
  final List<ActivityLog> _logs = [];

  @override
  List<User> getStaffList() => List.unmodifiable(_users);

  @override
  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  User? getUserByUsername(String username) {
    try {
      return _users.firstWhere((u) => u.username.toLowerCase() == username.trim().toLowerCase());
    } catch (_) {
      return null;
    }
  }

  @override
  void addUser(User user) {
    _users.add(user);
  }

  @override
  void updateUser(User user) {
    final idx = _users.indexWhere((u) => u.id == user.id);
    if (idx != -1) _users[idx] = user;
  }

  @override
  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
  }

  @override
  List<ActivityLog> getActivityLogs() => List.unmodifiable(_logs);

  @override
  void logActivity(ActivityLog log) {
    _logs.insert(0, log);
  }

  @override
  void loadDemoData() {
    // Keep owner intact, add demo staff
    _logs.clear();
    _logs.addAll(DemoData.activityLogs);
    if (!_users.any((u) => u.username == 'ali')) {
      _users.add(
        const User(
          id: 'staff-2',
          name: 'Ali Raza',
          username: 'ali',
          password: '123',
          role: UserRole.staff,
          phone: '0304-9876543',
          isActive: true,
        ),
      );
    }
    if (!_users.any((u) => u.username == 'usman')) {
      _users.add(
        const User(
          id: 'staff-3',
          name: 'Usman Ghani',
          username: 'usman',
          password: '123',
          role: UserRole.staff,
          phone: '0308-1122334',
          isActive: true,
        ),
      );
    }
  }

  @override
  void clearData() {
    // Keep only owner if present
    _users.removeWhere((u) => u.role != UserRole.owner);
    _logs.clear();
  }
}

