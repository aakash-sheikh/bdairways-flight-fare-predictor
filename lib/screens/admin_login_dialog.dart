import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

Future<void> showAdminLogin(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AdminLoginDialog(),
  );
}

class _AdminLoginDialog extends StatefulWidget {
  const _AdminLoginDialog();

  @override
  State<_AdminLoginDialog> createState() => _AdminLoginDialogState();
}

class _AdminLoginDialogState extends State<_AdminLoginDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _busy = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'Sign-in failed ($code).';
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.signIn(_email.text, _password.text);
      if (!AuthService.isAdmin(_auth.currentUser)) {
        await _auth.signOut();
        setState(() => _error = 'This account is not an admin.');
        return;
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _message(e.code));
    } catch (_) {
      setState(() => _error = 'Sign-in failed. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Row(
        children: [
          Icon(Icons.lock_outline, color: AppColors.navy),
          SizedBox(width: 10),
          Text('Admin sign in',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy)),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _email,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.username],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: _hide,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: const TextStyle(color: AppColors.red, fontSize: 13)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Sign in'),
        ),
      ],
    );
  }
}
