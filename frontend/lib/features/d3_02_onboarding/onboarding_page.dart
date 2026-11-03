import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import '../../core/widgets/theme_mode_button.dart';
import 'onboarding_api.dart';
import 'onboarding_validators.dart';

/// D3-02 · Onboarding: hồ sơ thương hiệu ban đầu (E7.1). Bước 2 là D3-05 (Google Place ID).
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.session});

  final SessionController session;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandName = TextEditingController();
  final _branchName = TextEditingController();
  final _phone = TextEditingController();
  final _color = TextEditingController(text: defaultBrandColor);
  late final _onboardingApi = OnboardingApi(widget.session.api);

  String? _industry;
  Uint8List? _logoBytes;
  String? _logoExtension;
  String? _logoError;
  bool _busy = false;
  String? _error;
  Map<String, String> _serverErrors = const {};

  @override
  void dispose() {
    _brandName.dispose();
    _branchName.dispose();
    _phone.dispose();
    _color.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (file == null) return;
    final extension = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : '';
    if (logoContentType(file.name) == null) {
      setState(() => _logoError = 'Chỉ hỗ trợ ảnh PNG, JPG hoặc WEBP.');
      return;
    }
    final bytes = await file.readAsBytes();
    if (bytes.length > maxLogoBytes) {
      setState(() => _logoError = 'Logo tối đa 2 MB.');
      return;
    }
    setState(() {
      _logoBytes = bytes;
      _logoExtension = extension == 'jpeg' ? 'jpg' : extension;
      _logoError = null;
    });
  }

  Future<void> _submit() async {
    setState(() => _serverErrors = const {});
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      String? logoUrl;
      if (_logoBytes != null) {
        logoUrl = await _onboardingApi.uploadLogo(
          bytes: _logoBytes!,
          extension: _logoExtension!,
          contentType: logoContentTypes[_logoExtension!]!,
        );
      }
      await _onboardingApi.submit(
        brandName: _brandName.text.trim(),
        branchName: _branchName.text.trim(),
        industry: _industry!,
        phone: normalizePhone(_phone.text),
        primaryColor: _color.text.trim().toUpperCase(),
        logoUrl: logoUrl,
      );
      await widget.session.reloadProfile();
      if (mounted) context.go('/funnel/google-place?step=onboarding');
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _serverErrors = e.fieldErrors;
      });
      _formKey.currentState!.validate();
    } on StorageException catch (e) {
      setState(() => _error = 'Không tải được logo lên: ${e.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _withServerError(String field, String? localError) => localError ?? _serverErrors[field];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Thiết lập hồ sơ cơ sở', style: theme.textTheme.headlineSmall)),
                      const ThemeModeButton(),
                      TextButton.icon(
                        onPressed: _busy ? null : widget.session.signOut,
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('Đăng xuất'),
                        style: TextButton.styleFrom(foregroundColor: context.colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bước 1/2 · Thông tin cơ sở và nhận diện ban đầu',
                    style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const _StepProgress(current: 1, total: 2),
                  const SizedBox(height: 24),
                  const NoticeBanner(
                    message: 'Sau bước này hệ thống tạo cơ sở, chi nhánh đầu tiên và gán bạn vai trò Chủ cơ sở. '
                        'Bạn có thể đổi các thông tin này trong phần Cài đặt.',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    NoticeBanner(message: _error!, type: NoticeType.error),
                  ],
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TwoColumns(
                            left: _field(
                              label: 'Tên thương hiệu',
                              required: true,
                              child: TextFormField(
                                controller: _brandName,
                                decoration: const InputDecoration(hintText: 'Ví dụ: Maison Coffee & Bistro'),
                                validator: (v) => _withServerError('brandName', validateBrandName(v)),
                                enabled: !_busy,
                              ),
                            ),
                            right: _field(
                              label: 'Tên cơ sở / chi nhánh',
                              child: TextFormField(
                                controller: _branchName,
                                decoration: const InputDecoration(
                                  hintText: 'Tên hiển thị',
                                  helperText: 'Dùng làm tên chi nhánh đầu tiên; để trống sẽ lấy tên thương hiệu.',
                                ),
                                validator: (v) => _withServerError('branchName', validateBranchName(v)),
                                enabled: !_busy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _TwoColumns(
                            left: _field(
                              label: 'Ngành nghề',
                              required: true,
                              child: DropdownButtonFormField<String>(
                                initialValue: _industry,
                                hint: const Text('Chọn ngành nghề'),
                                items: [
                                  for (final industry in industries)
                                    DropdownMenuItem(value: industry, child: Text(industry)),
                                ],
                                onChanged: _busy ? null : (value) => setState(() => _industry = value),
                                validator: (v) => _withServerError('industry', v == null ? 'Vui lòng chọn ngành nghề.' : null),
                              ),
                            ),
                            right: _field(
                              label: 'Số điện thoại',
                              child: TextFormField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(hintText: 'Nhập số điện thoại'),
                                validator: (v) => _withServerError('phone', validatePhone(v)),
                                enabled: !_busy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Wrap(
                            spacing: 40,
                            runSpacing: 24,
                            children: [
                              _field(label: 'Logo thương hiệu', child: _buildLogoPicker()),
                              _field(label: 'Màu thương hiệu', child: _buildColorPicker()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 200,
                      child: FilledButton(
                        onPressed: _busy ? null : _submit,
                        child: _busy
                            ? SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onAccent),
                              )
                            : const Text('Tiếp tục'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child, bool required = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [FormLabel(label, required: required), child],
    );
  }

  Widget _buildLogoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _busy ? null : _pickLogo,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 170,
            height: 120,
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _logoError != null ? context.colors.error : context.colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _logoBytes != null
                ? Image.memory(_logoBytes!, fit: BoxFit.contain)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, color: context.colors.textSecondary),
                      SizedBox(height: 6),
                      Text('Tải logo lên', style: TextStyle(color: context.colors.textSecondary)),
                      Text('PNG, JPG, WEBP · tối đa 2 MB', style: TextStyle(fontSize: 11, color: context.colors.textMuted)),
                    ],
                  ),
          ),
        ),
        if (_logoBytes != null)
          TextButton(
            onPressed: _busy ? null : () => setState(() => _logoBytes = null),
            child: const Text('Xoá logo'),
          ),
        if (_logoError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(_logoError!, style: TextStyle(color: context.colors.error, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildColorPicker() {
    final color = parseHexColor(_color.text) ?? context.colors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.colors.border),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 250,
              child: TextFormField(
                controller: _color,
                decoration: const InputDecoration(hintText: '#333333', helperText: 'Mã màu'),
                onChanged: (_) => setState(() {}),
                validator: (v) => _withServerError('primaryColor', validateHexColor(v)),
                enabled: !_busy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in brandColorPresets)
              Tooltip(
                message: preset,
                child: InkWell(
                  onTap: _busy ? null : () => setState(() => _color.text = preset),
                  customBorder: const CircleBorder(),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: parseHexColor(preset),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color.text.toUpperCase() == preset ? context.colors.textPrimary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TwoColumns extends StatelessWidget {
  const _TwoColumns({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(children: [left, const SizedBox(height: 18), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: left), const SizedBox(width: 35), Expanded(child: right)],
        );
      },
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= total; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? context.colors.accent : context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
