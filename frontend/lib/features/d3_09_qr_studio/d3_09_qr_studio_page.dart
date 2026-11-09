import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import '../d3_11_print_nfc/print_nfc_api.dart';
import '../d3_11_print_nfc/print_nfc_models.dart';

/// Màn hình D3-09: Studio thiết kế ấn phẩm QR (User Story 1 - E5.1)
/// Thiết kế Standee để bàn & Sticker dán quầy thu ngân cho chi nhánh
class D309QrStudioPage extends StatefulWidget {
  const D309QrStudioPage({super.key, required this.session, this.api});

  final SessionController session;
  final PrintNfcApi? api;

  @override
  State<D309QrStudioPage> createState() => _D309QrStudioPageState();
}

class _D309QrStudioPageState extends State<D309QrStudioPage> {
  late final PrintNfcApi _api = widget.api ?? PrintNfcApi(widget.session.api);

  bool _loading = true;
  String? _error;

  List<QrCodeDto> _qrCodes = [];
  List<PrintDesignDto> _designs = [];

  // Thuộc tính thiết kế hiện tại
  String _currentDesignId = '';
  String _selectedBranchId = '';
  String _selectedQrCode = 'MC-B04';
  String _selectedQrCodeId = 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33';

  // Khung mẫu: TABLE_TENT (Standee bàn), COUNTER_STAND (Đế mica), WINDOW_STICKER (Sticker quầy), CARD_NFC (Thẻ chạm NFC)
  String _selectedTemplate = 'TABLE_TENT';

  final _brandNameController = TextEditingController(text: 'Maison Coffee & Bistro');
  final _ctaTextController = TextEditingController(text: 'Quét mã để đánh giá & nhận ưu đãi');
  final _logoUrlController = TextEditingController(text: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=200&auto=format&fit=crop&q=80');

  String _selectedColor = '#2C1810';
  String _selectedFormat = 'PDF';
  String _selectedSize = 'A6';
  bool _saving = false;

  final List<Map<String, String>> _colorPresets = [
    {'name': 'Nâu Cà phê', 'hex': '#2C1810'},
    {'name': 'Xanh Navy', 'hex': '#1E3A8A'},
    {'name': 'Đỏ Rượu', 'hex': '#991B1B'},
    {'name': 'Xanh Ngọc', 'hex': '#0D9488'},
    {'name': 'Tím Indigo', 'hex': '#4338CA'},
    {'name': 'Cam Đồng', 'hex': '#C2410C'},
  ];

  final List<String> _ctaSuggestions = [
    'Quét mã để đánh giá & nhận ưu đãi',
    'Góp ý dịch vụ nhận ngay quà tri ân',
    'Chạm NFC hoặc quét QR để phản hồi',
    'Đánh giá 5 sao nhận ngay quà tặng',
    'Cảm ơn bạn đã ghé thăm quán hôm nay',
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _brandNameController.dispose();
    _ctaTextController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final businessId = widget.session.business?.id ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
      final defaultBranch = widget.session.selectedBranch ??
          (widget.session.branches.isNotEmpty ? widget.session.branches.first : null);
      _selectedBranchId = defaultBranch?.id ?? 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22';

      // 1. Tải danh sách mã QR của chi nhánh (E5.1: Tạo mã QR cho chi nhánh nếu chưa có)
      var qrs = await _api.getQrCodes(branchId: _selectedBranchId);
      if (qrs.isEmpty) {
        final createdDefault = await _api.ensureDefaultQrCode(branchId: _selectedBranchId);
        qrs = [createdDefault];
      }

      // 2. Tải danh sách mẫu thiết kế đã lưu
      final designs = await _api.getDesigns(businessId: businessId);

      if (!mounted) return;

      setState(() {
        _qrCodes = qrs;
        _designs = designs;

        if (qrs.isNotEmpty) {
          _selectedQrCode = qrs.first.code;
          _selectedQrCodeId = qrs.first.id;
        }

        if (designs.isNotEmpty) {
          _applyDesign(designs.first);
        } else {
          _brandNameController.text = widget.session.business?.displayName ?? 'Maison Coffee & Bistro';
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyDesign(PrintDesignDto design) {
    _currentDesignId = design.id;
    _selectedQrCodeId = design.qrCodeId;
    _selectedQrCode = design.qrCodeValue;
    _selectedTemplate = design.template;
    _brandNameController.text = design.brandName;
    _ctaTextController.text = design.ctaText;
    _selectedColor = design.color;
    if (design.logoUrl != null && design.logoUrl!.isNotEmpty) {
      _logoUrlController.text = design.logoUrl!;
    }
    _selectedFormat = design.exportFormat;
    _selectedSize = design.size;
  }

  Future<void> _handleSaveDesign({bool asNew = false}) async {
    setState(() => _saving = true);

    try {
      final businessId = widget.session.business?.id ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
      final dto = PrintDesignDto(
        id: asNew ? '' : _currentDesignId,
        businessId: businessId,
        qrCodeId: _selectedQrCodeId,
        qrCodeValue: _selectedQrCode,
        targetUrl: 'https://cxshield.vn/survey?qr=$_selectedQrCode',
        template: _selectedTemplate,
        templateName: _getTemplateDisplayName(_selectedTemplate),
        brandName: _brandNameController.text.trim().isNotEmpty
            ? _brandNameController.text.trim()
            : 'Maison Coffee & Bistro',
        ctaText: _ctaTextController.text.trim().isNotEmpty
            ? _ctaTextController.text.trim()
            : 'Quét mã để đánh giá & nhận ưu đãi',
        color: _selectedColor,
        logoUrl: _logoUrlController.text.trim(),
        exportFormat: _selectedFormat,
        size: _selectedSize,
        downloadUrl: '',
      );

      final saved = await _api.saveDesign(dto);

      if (!mounted) return;

      setState(() {
        _currentDesignId = saved.id;
        final index = _designs.indexWhere((d) => d.id == saved.id);
        if (index >= 0) {
          _designs[index] = saved;
        } else {
          _designs.insert(0, saved);
        }
        _saving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(asNew
              ? 'Đã lưu thành mẫu thiết kế mới thành công!'
              : 'Đã lưu mẫu thiết kế ấn phẩm vào print_designs thành công!'),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thiết kế: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleDeleteDesign(String designId) async {
    try {
      await _api.deleteDesign(designId);
      if (!mounted) return;
      setState(() {
        _designs.removeWhere((d) => d.id == designId);
        if (_currentDesignId == designId) {
          _currentDesignId = '';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa mẫu thiết kế thành công!'), backgroundColor: Colors.black87),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa mẫu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showCreateQrDialog() async {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: 'Quầy thu ngân');
    String type = 'COUNTER';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tạo Mã QR Vị Trí Mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FormLabel('Loại vị trí'),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'COUNTER', child: Text('Quầy thu ngân (COUNTER)')),
                    DropdownMenuItem(value: 'TABLE', child: Text('Bàn ăn / phục vụ (TABLE)')),
                    DropdownMenuItem(value: 'AREA', child: Text('Khu vực chung / Sảnh (AREA)')),
                    DropdownMenuItem(value: 'STAFF', child: Text('Nhân viên phụ trách (STAFF)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        type = val;
                        if (type == 'TABLE') nameCtrl.text = 'Bàn mới';
                        if (type == 'COUNTER') nameCtrl.text = 'Quầy thu ngân';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                const FormLabel('Tên vị trí hiển thị'),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'VD: Bàn 05, Quầy thu ngân tầng 1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const FormLabel('Mã định danh QR (Tùy chọn)'),
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Để trống để tự sinh (VD: MC-QUAY02)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              child: const Text('Tạo mã QR'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      try {
        final req = QrCodeCreateRequest(
          branchId: _selectedBranchId,
          code: codeCtrl.text.trim().isNotEmpty ? codeCtrl.text.trim() : null,
          type: type,
          name: nameCtrl.text.trim(),
        );

        final newQr = await _api.createQrCode(req);

        if (!mounted) return;
        setState(() {
          _qrCodes.insert(0, newQr);
          _selectedQrCode = newQr.code;
          _selectedQrCodeId = newQr.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tạo mã QR mới thành công: ${newQr.code} (${newQr.name})'),
            backgroundColor: const Color(0xFF047857),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo mã QR: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _navigateToSurveyM101() {
    final surveyPath = '/survey?qr=$_selectedQrCode';
    try {
      context.push(surveyPath);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Điều hướng màn khách M1-01: $surveyPath')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            NoticeBanner(title: 'Không thể tải studio thiết kế', message: _error!, type: NoticeType.error),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _initData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colors),
              const SizedBox(height: 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildEditorForm(colors)),
                    const SizedBox(width: 24),
                    Expanded(flex: 5, child: _buildPreviewPane(colors)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildPreviewPane(colors),
                    const SizedBox(height: 24),
                    _buildEditorForm(colors),
                  ],
                ),
              const SizedBox(height: 36),
              _buildSavedDesignsSection(colors),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.palette_outlined, color: Color(0xFF1E3A8A), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Studio Thiết Kế Ấn Phẩm QR (D3-09)',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tự tạo Standee để bàn hoặc Sticker dán quầy thu ngân cho chi nhánh – Tiết kiệm chi phí thuê ngoài',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditorForm(AppColors colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Chọn Mã QR Chi Nhánh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedQrCode,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.qr_code_2),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _qrCodes.map((qr) {
                      return DropdownMenuItem(
                        value: qr.code,
                        child: Text(
                          '${qr.code} - ${qr.name} (${qr.type})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final found = _qrCodes.firstWhere((q) => q.code == val, orElse: () => _qrCodes.first);
                        setState(() {
                          _selectedQrCode = found.code;
                          _selectedQrCodeId = found.id;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _showCreateQrDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tạo mã QR'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('2. Chọn Khung Mẫu Ấn Phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 12),
            _buildTemplateSelector(colors),
            const SizedBox(height: 24),

            Text('3. Tùy Biến Thương Hiệu & Thông Điệp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary)),
            const SizedBox(height: 14),

            const FormLabel('Tên thương hiệu / Cơ sở'),
            TextField(
              controller: _brandNameController,
              decoration: const InputDecoration(
                hintText: 'Nhập tên thương hiệu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            const FormLabel('Logo cơ sở (URL ảnh)'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _logoUrlController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập URL hình ảnh logo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                if (_logoUrlController.text.isNotEmpty)
                  IconButton(
                    onPressed: () => setState(() => _logoUrlController.clear()),
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    tooltip: 'Xóa logo',
                  ),
              ],
            ),
            const SizedBox(height: 14),

            const FormLabel('Câu kêu gọi hành động (CTA)'),
            TextField(
              controller: _ctaTextController,
              decoration: const InputDecoration(
                hintText: 'VD: Quét mã để đánh giá & nhận ưu đãi',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.chat_bubble_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),

            // Gợi ý CTA nhanh
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _ctaSuggestions.map((cta) {
                return ActionChip(
                  label: Text(cta, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    setState(() => _ctaTextController.text = cta);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const FormLabel('Màu sắc nhận diện thương hiệu'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorPresets.map((preset) {
                final hex = preset['hex']!;
                final isSelected = _selectedColor.toUpperCase() == hex.toUpperCase();
                final c = _parseHex(hex);

                return ChoiceChip(
                  label: Text(preset['name']!),
                  avatar: CircleAvatar(backgroundColor: c, radius: 8),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedColor = hex);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Định dạng in'),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'PDF', label: Text('PDF Vector')),
                          ButtonSegment(value: 'PNG', label: Text('PNG 300 DPI')),
                        ],
                        selected: {_selectedFormat},
                        onSelectionChanged: (set) => setState(() => _selectedFormat = set.first),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormLabel('Kích cỡ'),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'A6', label: Text('A6 (Bàn)')),
                          ButtonSegment(value: 'A5', label: Text('A5 (Quầy)')),
                        ],
                        selected: {_selectedSize},
                        onSelectionChanged: (set) => setState(() => _selectedSize = set.first),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _handleSaveDesign(asNew: false),
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'Đang lưu...' : 'Lưu mẫu thiết kế'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : () => _handleSaveDesign(asNew: true),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Lưu bản sao mới'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(AppColors colors) {
    final templates = [
      {
        'id': 'TABLE_TENT',
        'title': 'Standee Để Bàn',
        'subtitle': 'Khung tam giác A6 (Bàn phục vụ)',
        'icon': Icons.tab_rounded,
      },
      {
        'id': 'COUNTER_STAND',
        'title': 'Đế Mica Để Quầy',
        'subtitle': 'Khung đứng A5 (Quầy thu ngân)',
        'icon': Icons.point_of_sale_rounded,
      },
      {
        'id': 'WINDOW_STICKER',
        'title': 'Sticker Dán Quầy',
        'subtitle': 'Decal tròn/vuông dán kính/quầy',
        'icon': Icons.verified_rounded,
      },
      {
        'id': 'CARD_NFC',
        'title': 'Thẻ Chạm NFC',
        'subtitle': 'Phôi gỗ/mica tích hợp NFC & QR',
        'icon': Icons.contactless_rounded,
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: templates.map((tpl) {
        final isSelected = _selectedTemplate == tpl['id'];
        final tplId = tpl['id'] as String;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedTemplate = tplId;
              if (tplId == 'COUNTER_STAND') _selectedSize = 'A5';
              if (tplId == 'TABLE_TENT') _selectedSize = 'A6';
            });
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E3A8A).withValues(alpha: 0.06) : colors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? const Color(0xFF1E3A8A) : colors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  tpl['icon'] as IconData,
                  color: isSelected ? const Color(0xFF1E3A8A) : colors.textSecondary,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tpl['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isSelected ? const Color(0xFF1E3A8A) : colors.textPrimary,
                        ),
                      ),
                      Text(
                        tpl['subtitle'] as String,
                        style: TextStyle(fontSize: 11, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewPane(AppColors colors) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Xem Trước Trực Tiếp (Live Preview)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF047857).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '✓ Real-time',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card mô phỏng thực tế
            _buildLiveVisualArtifact(),
            const SizedBox(height: 16),

            // Badge quét thật 100%
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mã QR thật 100% chuẩn ma trận – Camera điện thoại quét được ngay!',
                      style: TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Nút Thử nghiệm quét QR mở M1-01
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToSurveyM101,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text('Thử nghiệm quét QR: Mở màn khảo sát M1-01 ($_selectedQrCode)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF047857),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveVisualArtifact() {
    final brandColor = _parseHex(_selectedColor);
    final brandName = _brandNameController.text.trim().isNotEmpty
        ? _brandNameController.text.trim()
        : 'Maison Coffee & Bistro';
    final ctaText = _ctaTextController.text.trim().isNotEmpty
        ? _ctaTextController.text.trim()
        : 'Quét mã để đánh giá & nhận ưu đãi';
    final targetUrl = 'https://cxshield.vn/survey?qr=$_selectedQrCode';

    // Mẫu STICKER DÁN QUẦY (WINDOW_STICKER)
    if (_selectedTemplate == 'WINDOW_STICKER') {
      return Container(
        width: 270,
        height: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: brandColor, width: 6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                brandName.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: brandColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              // QR Code
              GestureDetector(
                onTap: _navigateToSurveyM101,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: QrImageView(
                    data: targetUrl,
                    version: QrVersions.auto,
                    size: 110.0,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: brandColor,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: brandColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ctaText,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'MÃ: $_selectedQrCode',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mẫu THẺ CHẠM NFC (CARD_NFC)
    if (_selectedTemplate == 'CARD_NFC') {
      return Container(
        width: 290,
        height: 190,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [brandColor, brandColor.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: brandColor.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                const Icon(Icons.contactless_rounded, color: Colors.white, size: 28),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: _navigateToSurveyM101,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: targetUrl,
                      version: QrVersions.auto,
                      size: 85.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black87,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctaText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MÃ: $_selectedQrCode',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'CHẠM ĐIỆN THOẠI ĐỂ ĐÁNH GIÁ',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text('NFC TAG 215', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      );
    }

    // Mặc định: STANDEE ĐỂ BÀN (TABLE_TENT) HOẶC ĐẾ MICA QUẦY (COUNTER_STAND)
    return Container(
      width: 260,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          // Banner thương hiệu
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_logoUrlController.text.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _logoUrlController.text.trim(),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    brandName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              ctaText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // QR Code thật có thể quét được
          GestureDetector(
            onTap: _navigateToSurveyM101,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
              ),
              child: QrImageView(
                data: targetUrl,
                version: QrVersions.auto,
                size: 135.0,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: brandColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: brandColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Mã bàn & NFC touch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'MÃ: $_selectedQrCode',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: brandColor,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.nfc_rounded, size: 14, color: Color(0xFF64748B)),
              SizedBox(width: 4),
              Text(
                'Chạm NFC hoặc quét QR',
                style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          // Chân đế mica/gỗ standee
          Container(
            height: 14,
            width: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSavedDesignsSection(AppColors colors) {
    if (_designs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mẫu Thiết Kế Đã Lưu (${_designs.length})',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _designs.map((d) {
            final isCurrent = d.id == _currentDesignId;
            final itemColor = _parseHex(d.color);

            return Container(
              width: 260,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF1E3A8A) : colors.border,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: itemColor, radius: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          d.brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () => _handleDeleteDesign(d.id),
                        tooltip: 'Xóa mẫu này',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mẫu: ${d.templateName} • QR: ${d.qrCodeValue}',
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CTA: "${d.ctaText}"',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _applyDesign(d));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Đã nạp mẫu: ${d.brandName}')),
                        );
                      },
                      child: Text(isCurrent ? 'Đang chỉnh sửa' : 'Nạp mẫu này'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF1E3A8A);
    }
  }

  String _getTemplateDisplayName(String template) {
    return switch (template) {
      'COUNTER_STAND' => 'Đế mica quầy thu ngân (A5)',
      'WINDOW_STICKER' => 'Decal dán cửa kính / quầy',
      'CARD_NFC' => 'Thẻ chạm NFC để bàn',
      _ => 'Biển để bàn tam giác (A6)',
    };
  }
}
