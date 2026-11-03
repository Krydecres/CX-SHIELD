import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/theme_mode_button.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import 'auth_error_messages.dart';

/// D3-01 · Đăng ký / đăng nhập (E7.1).
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isRegister = false;
  bool _obscure = true;
  bool _busy = false;
  String? _error;
  String? _info;

  GoTrueClient get _auth => Supabase.instance.client.auth;

  // Trên web quay lại đúng origin đang chạy (ví dụ http://localhost:3000) sau khi xác thực.
  String? get _redirectUrl => kIsWeb ? Uri.base.origin : null;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    await _run(() async {
      if (!_isRegister) {
        await _auth.signInWithPassword(email: email, password: _password.text);
        return;
      }
      final response = await _auth.signUp(email: email, password: _password.text, emailRedirectTo: _redirectUrl);
      // Khi bật xác nhận email, Supabase không báo lỗi với email đã tồn tại mà trả user không có identity.
      if (response.user != null && (response.user!.identities?.isEmpty ?? false)) {
        throw const AuthException('User already registered', code: 'user_already_exists');
      }
      if (response.session == null && mounted) {
        setState(() {
          _isRegister = false;
          _info = 'Đã gửi email xác nhận tới $email. Vui lòng mở hộp thư, bấm liên kết xác nhận rồi đăng nhập.';
        });
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    await _run(() async {
      await _auth.signInWithOAuth(OAuthProvider.google, redirectTo: _redirectUrl);
    });
  }

  Future<void> _forgotPassword() async {
    final error = validateEmail(_email.text);
    if (error != null) {
      setState(() {
        _info = null;
        _error = 'Nhập email của bạn vào ô Email rồi bấm "Quên mật khẩu?".';
      });
      return;
    }
    final email = _email.text.trim();
    await _run(() async {
      await _auth.resetPasswordForEmail(email, redirectTo: _redirectUrl);
      if (mounted) setState(() => _info = 'Đã gửi hướng dẫn đặt lại mật khẩu tới $email.');
    });
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
      _error = null;
      _info = null;
      _confirmPassword.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: const Padding(padding: EdgeInsets.only(top: 4), child: ThemeModeButton()),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProductMark(),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(_isRegister ? 'Tạo tài khoản' : 'Chào mừng bạn', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              'Tạo tài khoản hoặc đăng nhập để quản lý cơ sở.',
                              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: _busy ? null : _signInWithGoogle,
                              icon: const _GoogleMark(),
                              label: const Text('Tiếp tục với Google'),
                            ),
                            const SizedBox(height: 18),
                            const _OrDivider(),
                            const SizedBox(height: 18),
                            if (_error != null) ...[
                              NoticeBanner(message: _error!, type: NoticeType.error),
                              const SizedBox(height: 16),
                            ],
                            if (_info != null) ...[
                              NoticeBanner(message: _info!),
                              const SizedBox(height: 16),
                            ],
                            const FormLabel('Email'),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              decoration: const InputDecoration(hintText: 'name@example.com'),
                              validator: validateEmail,
                              enabled: !_busy,
                            ),
                            const SizedBox(height: 16),
                            const FormLabel('Mật khẩu'),
                            TextFormField(
                              controller: _password,
                              obscureText: _obscure,
                              autofillHints: [_isRegister ? AutofillHints.newPassword : AutofillHints.password],
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                suffixIcon: IconButton(
                                  tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => validatePassword(v, isRegister: _isRegister),
                              onFieldSubmitted: (_) => _isRegister ? null : _submit(),
                              enabled: !_busy,
                            ),
                            if (_isRegister) ...[
                              const SizedBox(height: 16),
                              const FormLabel('Nhập lại mật khẩu'),
                              TextFormField(
                                controller: _confirmPassword,
                                obscureText: _obscure,
                                decoration: const InputDecoration(hintText: '••••••••'),
                                validator: (v) => v != _password.text ? 'Mật khẩu nhập lại không khớp.' : null,
                                onFieldSubmitted: (_) => _submit(),
                                enabled: !_busy,
                              ),
                            ],
                            const SizedBox(height: 22),
                            FilledButton(
                              onPressed: _busy ? null : _submit,
                              child: _busy
                                  ? SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onAccent),
                                    )
                                  : Text(_isRegister ? 'Đăng ký' : 'Đăng nhập'),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(_isRegister ? 'Đã có tài khoản?' : 'Chưa có tài khoản?'),
                                TextButton(
                                  onPressed: _busy ? null : _toggleMode,
                                  child: Text(_isRegister ? 'Đăng nhập' : 'Đăng ký'),
                                ),
                              ],
                            ),
                            if (!_isRegister)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                  onPressed: _busy ? null : _forgotPassword,
                                  child: const Text('Quên mật khẩu?'),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductMark extends StatelessWidget {
  const _ProductMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: context.colors.sidebar, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.shield_outlined, color: context.colors.onSidebar, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'Review Funnel',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.secondary),
        ),
      ],
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.colors.border)),
      child: Text('G', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.secondary)),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('hoặc', style: TextStyle(color: context.colors.textMuted)),
        ),
        Expanded(child: Divider()),
      ],
    );
  }
}
