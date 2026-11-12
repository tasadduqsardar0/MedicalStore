import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models/user_model.dart';
import '../providers/auth_provider.dart';

/// RoleGuard enforces page-level access permissions.
/// If a staff member tries to open an owner-only page, they are
/// redirected back to the Dashboard and shown the exact required message:
/// "This page is for the owner only."
class RoleGuard extends StatefulWidget {
  final Widget child;
  final UserRole requiredRole;
  final bool allowRealOwner;
  final VoidCallback? onUnauthorized;

  const RoleGuard({
    super.key,
    required this.child,
    this.requiredRole = UserRole.owner,
    this.allowRealOwner = false,
    this.onUnauthorized,
  });

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccess();
    });
  }

  bool _isAuthorized(AuthProvider auth) {
    if (widget.allowRealOwner && auth.isRealOwner) return true;
    return auth.hasRole(widget.requiredRole);
  }

  void _checkAccess() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!_isAuthorized(auth)) {
      if (widget.onUnauthorized != null) {
        widget.onUnauthorized!();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This page is for the owner only.'),
            backgroundColor: Color(0xFFD64545),
            duration: Duration(seconds: 3),
          ),
        );
        // Pop or return to first route (Dashboard)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!_isAuthorized(auth)) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.child;
  }
}

