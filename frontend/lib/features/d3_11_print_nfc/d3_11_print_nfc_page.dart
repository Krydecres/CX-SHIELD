import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/form_label.dart';
import '../../core/widgets/notice_banner.dart';
import 'print_nfc_api.dart';
import 'print_nfc_models.dart';

class D311PrintNfcPage extends StatefulWidget {
  const D311PrintNfcPage({super.key, required this.session});

  final SessionController session;

  @override
  State<D311PrintNfcPage> createState() => _D311PrintNfcPageState();
}

class _D311PrintNfcPageState extends State<D311PrintNfcPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PrintNfcApi _api = PrintNfcApi(widget.session.api);

  bool _loading = true;
  String? _error;
  List<PrintDesignDto> _designs = [];
  List<NfcOrderDto> _orders = [];

  // Thiết kế hiện tại đang tùy chỉnh
  String _currentDesignId = '';
  String _selectedQrCode = 'MC-B04';
  String _selectedTemplate = 'TABLE_TENT';
  final _brandNameController = TextEditingController(text: 'Maison Coffee & Bistro');
  final _ctaTextController = TextEditingController(text: 'Quét mã để đánh giá & nhận ưu đãi');
  String _selectedColor = '#2C1810';
  String _selectedFormat = 'PDF';
  String _selectedSize = 'A6';

  // Form đặt phôi thẻ NFC
  final _orderFormKey = GlobalKey<FormState>();
  String _orderMaterial = 'WOOD'; // WOOD hoặc MICA
  int _orderQuantity = 10;
  final _shipNameController = TextEditingController();
  final _shipPhoneController = TextEditingController();
  final _shipAddressController = TextEditingController();
  bool _submittingOrder = false;

  final List<Map<String, String>> _colorPresets = [
    {'name': 'Nâu Cà phê', 'hex': '#2C1810'},
    {'name': 'Xanh Navy', 'hex': '#1E3A8A'},
    {'name': 'Đỏ Rượu', 'hex': '#991B1B'},
    {'name': 'Xanh Ngọc', 'hex': '#0D9488'},
    {'name': 'Tím Indigo', 'hex': '#4338CA'},
  ];

  static final RegExp _vnPhoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _brandNameController.dispose();
    _ctaTextController.dispose();
    _shipNameController.dispose();
    _shipPhoneController.dispose();
    _shipAddressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final businessId = widget.session.business?.id;
      final designs = await _api.getDesigns(businessId: businessId);
      final orders = await _api.getNfcOrders(businessId: businessId);

      if (!mounted) return;

      setState(() {
        _designs = designs;
        _orders = orders;
        if (designs.isNotEmpty) {
          final first = designs.first;
          _currentDesignId = first.id;
          _selectedQrCode = first.qrCodeValue;
          _selectedTemplate = first.template;
          _brandNameController.text = first.brandName;
          _ctaTextController.text = first.ctaText;
          _selectedColor = first.color;
          _selectedFormat = first.exportFormat;
          _selectedSize = first.size;
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

  Future<void> _handleSaveDesign() async {
    try {
      final businessId = widget.session.business?.id ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
      final dto = PrintDesignDto(
        id: _currentDesignId,
        businessId: businessId,
        qrCodeId: 'c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33',
        qrCodeValue: _selectedQrCode,
        targetUrl: 'https://cxshield.vn/survey?qr=$_selectedQrCode',
        template: _selectedTemplate,
        templateName: _getTemplateDisplayName(_selectedTemplate),
        brandName: _brandNameController.text.trim(),
        ctaText: _ctaTextController.text.trim(),
        color: _selectedColor,
        exportFormat: _selectedFormat,
        size: _selectedSize,
        downloadUrl: '',
      );

      final saved = await _api.saveDesign(dto);

      if (!mounted) return;
      setState(() {
        _currentDesignId = saved.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu mẫu thiết kế ấn phẩm thành công!'),
          backgroundColor: Color(0xFF1E3A8A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu thiết kế: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleExportPrintFile() async {
    final designId = _currentDesignId.isNotEmpty
        ? _currentDesignId
        : (_designs.isNotEmpty ? _designs.first.id : 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55');

    final url = _api.getExportUrl(
      designId: designId,
      format: _selectedFormat.toLowerCase(),
      dpi: 300,
    );

    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang tải file ấn phẩm chuẩn in ấn (300 DPI, định dạng $_selectedFormat)...'),
        backgroundColor: const Color(0xFF047857),
      ),
    );
  }

  Future<void> _handleOrderNfc() async {
    if (!_orderFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _submittingOrder = true);

    try {
      final businessId = widget.session.business?.id ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
      final designId = _currentDesignId.isNotEmpty
          ? _currentDesignId
          : (_designs.isNotEmpty ? _designs.first.id : 'e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55');

      final req = NfcOrderCreateRequest(
        businessId: businessId,
        designId: designId,
        material: _orderMaterial,
        quantity: _orderQuantity,
        shipName: _shipNameController.text.trim(),
        shipPhone: _shipPhoneController.text.trim(),
        shipAddress: _shipAddressController.text.trim(),
      );

      final newOrder = await _api.createNfcOrder(req);

      if (!mounted) return;

      setState(() {
        _orders.insert(0, newOrder);
        _submittingOrder = false;
        _shipNameController.clear();
        _shipPhoneController.clear();
        _shipAddressController.clear();
        _orderQuantity = 10;
      });

      // Hiển thị dialog xác nhận thành công
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF047857)),
              SizedBox(width: 8),
              Text('Đặt hàng thành công!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn hàng: ${newOrder.id.length > 8 ? newOrder.id.substring(0, 8) : newOrder.id}'),
              const SizedBox(height: 6),
              Text('Chất liệu: ${newOrder.materialLabel}'),
              Text('Số lượng: ${newOrder.quantity} thẻ'),
              Text('Tổng tiền: ${_formatMoney(newOrder.totalAmount)}'),
              const SizedBox(height: 6),
              const Text(
                'Thẻ NFC đã được nạp sẵn link phễu khảo sát và sẽ giao tận nơi sau 2-3 ngày làm việc.',
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _tabController.animateTo(2); // Chuyển sang Tab Lịch sử đơn
              },
              child: const Text('Xem lịch sử đơn'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submittingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đơn hàng: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _getTemplateDisplayName(String template) {
    switch (template) {
      case 'TABLE_TENT':
        return 'Biển để bàn tam giác (A6)';
      case 'COUNTER_STAND':
        return 'Đế mica quầy thu ngân (A5)';
      case 'WINDOW_STICKER':
        return 'Decal dán cửa kính / quầy';
      case 'CARD_NFC':
        return 'Thẻ chạm NFC để bàn';
      default:
        return 'Biển để bàn tam giác (A6)';
    }
  }

  String _formatMoney(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')} đ';
  }

  Color _parseHex(String hex) {
    try {
      String clean = hex.replaceAll('#', '');
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return const Color(0xFF1E3A8A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(colors),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1E3A8A),
              unselectedLabelColor: colors.textMuted,
              indicatorColor: const Color(0xFF1E3A8A),
              tabs: [
                const Tab(icon: Icon(Icons.print_outlined), text: 'Xuất file in ấn (PDF / PNG)'),
                const Tab(icon: Icon(Icons.nfc_outlined), text: 'Đặt phôi thẻ NFC vật lý'),
                Tab(icon: const Icon(Icons.receipt_long_outlined), text: 'Lịch sử đơn hàng (${_orders.length})'),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                NoticeBanner(
                                  type: NoticeType.error,
                                  title: 'Không thể tải dữ liệu',
                                  message: _error!,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadData,
                                  child: const Text('Thử lại'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildExportTab(colors),
                            _buildOrderNfcTab(colors),
                            _buildHistoryTab(colors),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'D3-11 • Ấn phẩm QR / NFC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
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
                  'Chuẩn in ấn ≥ 300 DPI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Xuất file in ấn chất lượng cao & Đặt phôi thẻ NFC',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tạo ấn phẩm để bàn hoặc dán quầy thu ngân cho khách quét QR, hoặc đặt mua phôi thẻ chạm NFC nạp sẵn link phễu.',
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          ),
        ],
      ),
    );
  }

  // TAB 1: Xuất file in ấn (PDF/PNG)
  Widget _buildExportTab(AppColors colors) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        final controls = SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel('Vị trí đặt / Mã QR nguồn', required: true),
              DropdownButtonFormField<String>(
                value: _selectedQrCode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'MC-B04', child: Text('Bàn 04 (MC-B04) - Chi nhánh Q1')),
                  DropdownMenuItem(value: 'MC-B01', child: Text('Bàn 01 (MC-B01) - Chi nhánh Q1')),
                  DropdownMenuItem(value: 'MC-COUNTER', child: Text('Quầy thu ngân (MC-COUNTER)')),
                  DropdownMenuItem(value: 'MC-DOOR', child: Text('Cửa ra vào (MC-DOOR)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedQrCode = val);
                },
              ),
              const SizedBox(height: 16),

              const FormLabel('Kiểu mẫu ấn phẩm'),
              DropdownButtonFormField<String>(
                value: _selectedTemplate,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: 'TABLE_TENT', child: Text('Biển để bàn tam giác (A6)')),
                  DropdownMenuItem(value: 'COUNTER_STAND', child: Text('Đế mica quầy thu ngân (A5)')),
                  DropdownMenuItem(value: 'WINDOW_STICKER', child: Text('Decal dán cửa kính / quầy')),
                  DropdownMenuItem(value: 'CARD_NFC', child: Text('Thẻ chạm NFC để bàn')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTemplate = val);
                },
              ),
              const SizedBox(height: 16),

              const FormLabel('Tên thương hiệu hiển thị', required: true),
              TextField(
                controller: _brandNameController,
                decoration: InputDecoration(
                  hintText: 'Nhập tên thương hiệu cơ sở',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              const FormLabel('Câu kêu gọi hành động (CTA)'),
              TextField(
                controller: _ctaTextController,
                decoration: InputDecoration(
                  hintText: 'VD: Quét mã để đánh giá & nhận ưu đãi',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
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
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const FormLabel('Định dạng xuất'),
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
                        const FormLabel('Kích cỡ in'),
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
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _handleExportPrintFile,
                      icon: const Icon(Icons.download_rounded),
                      label: Text('Tải File In Ấn ($_selectedFormat - 300 DPI)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF047857),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _handleSaveDesign,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Lưu thiết kế'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

        final preview = Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          color: colors.surface.withValues(alpha: 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mô phỏng bản in thực tế (${_selectedSize} • ≥ 300 DPI)',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildLivePreviewCard(colors),
              const SizedBox(height: 12),
              const Text(
                '✓ Mã QR được tạo ma trận chuẩn sắc nét, máy ảnh điện thoại quét được ngay lập tức.',
                style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: controls),
              const VerticalDivider(width: 1),
              Expanded(flex: 4, child: preview),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                controls,
                const Divider(),
                preview,
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildLivePreviewCard(AppColors colors) {
    final brandColor = _parseHex(_selectedColor);

    return Container(
      width: 260,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          // Banner thương hiệu
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _brandNameController.text.trim().isNotEmpty
                  ? _brandNameController.text.trim()
                  : 'Maison Coffee & Bistro',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _ctaTextController.text.trim().isNotEmpty
                  ? _ctaTextController.text.trim()
                  : 'Quét mã để đánh giá & nhận ưu đãi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Khung hiển thị QR code
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded, size: 120, color: brandColor),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star_rounded, size: 18, color: brandColor),
                ),
              ],
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
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '300 DPI Vector Print Ready',
              style: TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Đặt phôi thẻ NFC vật lý (User Story 3 / E5.3)
  Widget _buildOrderNfcTab(AppColors colors) {
    final unitPrice = _orderMaterial == 'WOOD' ? 45000 : 35000;
    final totalAmount = unitPrice * _orderQuantity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _orderFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.nfc_rounded, color: Color(0xFF1D4ED8), size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Thẻ NFC vật lý được tích hợp sẵn chip cảm ứng NTAG. Khi khách chạm điện thoại, màn hình khảo sát phễu mở ra ngay lập tức mà không cần mở máy ảnh quét mã.',
                          style: TextStyle(color: Color(0xFF1E40AF), fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  '1. Chọn loại chất liệu phôi thẻ NFC',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMaterialCard(
                        material: 'WOOD',
                        title: 'Thẻ Gỗ Walnut sang trọng',
                        desc: 'Gỗ tự nhiên dẻ gai / óc chó, khắc laser sắc sảo, chống ẩm',
                        price: '45.000 đ / thẻ',
                        icon: Icons.forest_outlined,
                        isSelected: _orderMaterial == 'WOOD',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMaterialCard(
                        material: 'MICA',
                        title: 'Thẻ Mica Acrylic trong suốt',
                        desc: 'Nhựa Acrylic cao cấp, chống nước 100%, bóng đẹp, hiện đại',
                        price: '35.000 đ / thẻ',
                        icon: Icons.layers_outlined,
                        isSelected: _orderMaterial == 'MICA',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  '2. Số lượng thẻ cần đặt',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton.filledTonal(
                      onPressed: _orderQuantity > 1 ? () => setState(() => _orderQuantity--) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '$_orderQuantity',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => setState(() => _orderQuantity++),
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      'Tạm tính: ${_formatMoney(totalAmount)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '✓ Miễn phí nạp sẵn link phễu khảo sát và cấu hình mã bàn vào từng thẻ.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),

                const Text(
                  '3. Thông tin giao hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                const FormLabel('Họ và tên người nhận', required: true),
                TextFormField(
                  controller: _shipNameController,
                  decoration: InputDecoration(
                    hintText: 'Nhập họ tên người nhận thẻ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập họ và tên người nhận';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const FormLabel('Số điện thoại nhận hàng (Định dạng Việt Nam)', required: true),
                TextFormField(
                  controller: _shipPhoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
                  decoration: InputDecoration(
                    hintText: 'VD: 0901234567 hoặc 0987654321',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại nhận hàng';
                    }
                    if (!_vnPhoneRegex.hasMatch(v.trim())) {
                      return 'Số điện thoại không đúng định dạng Việt Nam (10 chữ số, đầu 03/05/07/08/09)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const FormLabel('Địa chỉ giao hàng', required: true),
                TextFormField(
                  controller: _shipAddressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nhập số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 5) {
                      return 'Vui lòng nhập địa chỉ giao hàng chi tiết (tối thiểu 5 ký tự)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tóm tắt đơn hàng & nút gửi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Đơn giá phôi thẻ:'),
                          Text('${_formatMoney(unitPrice)} / thẻ'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số lượng đặt:'),
                          Text('$_orderQuantity thẻ'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Thời gian giao hàng dự kiến:'),
                          Text('2-3 ngày làm việc', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            _formatMoney(totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF047857)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _submittingOrder ? null : _handleOrderNfc,
                    icon: _submittingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.shopping_cart_checkout_rounded),
                    label: Text(
                      _submittingOrder ? 'Đang gửi đơn hàng...' : 'Gửi Đơn Đặt Mua Phôi Thẻ NFC',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildMaterialCard({
    required String material,
    required String title,
    required String desc,
    required String price,
    required IconData icon,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => setState(() => _orderMaterial = material),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF64748B)),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF1D4ED8), size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAB 3: Lịch sử đơn hàng NFC
  Widget _buildHistoryTab(AppColors colors) {
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              const Text(
                'Chưa có đơn đặt phôi thẻ NFC nào',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hãy tạo đơn đặt phôi thẻ gỗ hoặc mica ở Tab Đặt phôi thẻ NFC để nhận thẻ hoàn thiện sau 2-3 ngày.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: const Text('Đặt phôi thẻ ngay'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orders[index];
        final orderShortId = order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id;

        return Card(
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đơn hàng #$orderShortId',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    _buildStatusChip(order.status, order.statusLabel),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Chip(
                      label: Text(order.materialLabel),
                      avatar: Icon(
                        order.material == 'WOOD' ? Icons.forest_outlined : Icons.layers_outlined,
                        size: 16,
                      ),
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${order.quantity} thẻ'),
                      backgroundColor: const Color(0xFFF1F5F9),
                    ),
                    const Spacer(),
                    Text(
                      _formatMoney(order.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text('${order.shipName} (${order.shipPhone})', style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.shipAddress,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status, String label) {
    Color bg;
    Color fg;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'PROCESSING':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF1D4ED8);
        break;
      case 'SHIPPED':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
      case 'DELIVERED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
