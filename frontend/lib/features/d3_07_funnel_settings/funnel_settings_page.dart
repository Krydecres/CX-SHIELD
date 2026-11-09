import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/notice_banner.dart';
import 'funnel_settings_api.dart';
import 'funnel_settings_models.dart';

/// D3-07 · Cài đặt phễu: từ khóa gợi ý & ngưỡng chia luồng (E4.3)
class FunnelSettingsPage extends StatefulWidget {
  const FunnelSettingsPage({super.key, required this.session});

  final SessionController session;

  @override
  State<FunnelSettingsPage> createState() => _FunnelSettingsPageState();
}

class _FunnelSettingsPageState extends State<FunnelSettingsPage> {
  late final _api = FunnelSettingsApi(widget.session.api);

  String? _businessId;
  bool _loading = true;
  String? _errorMessage;
  ({String text, NoticeType type})? _bannerNotice;

  // Dữ liệu Routing Rule
  RoutingRuleModel? _routingRule;
  bool _savingRouting = false;

  // Dữ liệu Từ khóa
  List<ReviewKeywordModel> _keywords = [];
  List<IndustryTemplateModel> _templates = [];
  String _selectedIndustry = 'F&B';
  final _newKeywordController = TextEditingController();
  bool _addingKeyword = false;

  // Live preview preview state
  final Set<String> _previewSelectedKeywords = {};

  bool get _canEdit => widget.session.membership?.canManageFunnel ?? false;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    _newKeywordController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    final bizId = widget.session.business?.id;
    if (bizId != null && bizId != _businessId) {
      _businessId = bizId;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final bizId = _businessId;
    if (bizId == null) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
      _bannerNotice = null;
    });

    try {
      final rule = await _api.loadRoutingRule(bizId);
      final keywords = await _api.loadKeywords(bizId);
      final templates = await _api.loadIndustryTemplates();

      if (!mounted) return;
      setState(() {
        _routingRule = rule;
        _keywords = keywords;
        _templates = templates;

        // Mặc định chọn 2 từ khóa đầu tiên cho Live Preview
        _previewSelectedKeywords.clear();
        final activeList = keywords.where((k) => k.active).toList();
        for (int i = 0; i < 2 && i < activeList.length; i++) {
          _previewSelectedKeywords.add(activeList[i].keyword);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveRoutingRule({required int minScore, required bool publicEnabled}) async {
    final bizId = _businessId;
    if (bizId == null || !_canEdit) return;

    setState(() => _savingRouting = true);
    try {
      final updated = await _api.updateRoutingRule(
        bizId,
        minScore: minScore,
        maxScore: 5,
        publicReviewEnabled: publicEnabled,
      );
      if (!mounted) return;
      setState(() {
        _routingRule = updated;
        _bannerNotice = (
          text: 'Đã lưu cấu hình ngưỡng phân luồng thành công! Áp dụng ngay lập tức cho màn khách quét QR.',
          type: NoticeType.success,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _bannerNotice = (text: 'Lỗi lưu cấu hình: $e', type: NoticeType.error);
        });
      }
    } finally {
      if (mounted) setState(() => _savingRouting = false);
    }
  }

  Future<void> _addKeyword() async {
    final text = _newKeywordController.text.trim();
    final bizId = _businessId;
    if (text.isEmpty || bizId == null || !_canEdit) return;

    setState(() => _addingKeyword = true);
    try {
      final created = await _api.addKeyword(bizId, text, industry: _selectedIndustry);
      _newKeywordController.clear();
      if (!mounted) return;
      setState(() {
        _keywords.add(created);
        _previewSelectedKeywords.add(created.keyword);
        _bannerNotice = (text: 'Đã thêm từ khóa "$text"', type: NoticeType.success);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _bannerNotice = (text: 'Lỗi thêm từ khóa: $e', type: NoticeType.error));
      }
    } finally {
      if (mounted) setState(() => _addingKeyword = false);
    }
  }

  Future<void> _toggleKeyword(ReviewKeywordModel kw) async {
    final bizId = _businessId;
    if (bizId == null || !_canEdit) return;

    final newActive = !kw.active;
    setState(() {
      final idx = _keywords.indexWhere((k) => k.id == kw.id);
      if (idx != -1) _keywords[idx] = kw.copyWith(active: newActive);
      if (!newActive) _previewSelectedKeywords.remove(kw.keyword);
    });

    try {
      await _api.updateKeyword(bizId, kw.id, active: newActive);
    } catch (e) {
      // Revert if error
      if (mounted) {
        setState(() {
          final idx = _keywords.indexWhere((k) => k.id == kw.id);
          if (idx != -1) _keywords[idx] = kw;
          _bannerNotice = (text: 'Lỗi cập nhật từ khóa: $e', type: NoticeType.error);
        });
      }
    }
  }

  Future<void> _deleteKeyword(ReviewKeywordModel kw) async {
    final bizId = _businessId;
    if (bizId == null || !_canEdit) return;

    setState(() {
      _keywords.removeWhere((k) => k.id == kw.id);
      _previewSelectedKeywords.remove(kw.keyword);
    });

    try {
      await _api.deleteKeyword(bizId, kw.id);
      if (mounted) {
        setState(() => _bannerNotice = (text: 'Đã xóa từ khóa "${kw.keyword}"', type: NoticeType.info));
      }
    } catch (e) {
      if (mounted) {
        _loadData();
        setState(() => _bannerNotice = (text: 'Lỗi xóa từ khóa: $e', type: NoticeType.error));
      }
    }
  }

  Future<void> _confirmApplyTemplate(String industry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Áp dụng bộ từ khóa mẫu?'),
        content: Text(
          'Hệ thống sẽ thay thế danh sách từ khóa hiện tại bằng bộ từ khóa chuẩn SEO ngành $industry. '
          'Bạn vẫn có thể thêm, sửa, xóa sau khi áp dụng.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Đồng ý áp dụng')),
        ],
      ),
    );

    if (confirmed != true) return;
    final bizId = _businessId;
    if (bizId == null || !_canEdit) return;

    setState(() => _loading = true);
    try {
      final updatedList = await _api.applyIndustryTemplate(bizId, industry);
      if (!mounted) return;
      setState(() {
        _keywords = updatedList;
        _previewSelectedKeywords.clear();
        for (int i = 0; i < 2 && i < updatedList.length; i++) {
          _previewSelectedKeywords.add(updatedList[i].keyword);
        }
        _bannerNotice = (
          text: 'Đã áp dụng thành công bộ từ khóa mẫu ngành $industry!',
          type: NoticeType.success,
        );
      });
    } catch (e) {
      if (mounted) {
        setState(() => _bannerNotice = (text: 'Lỗi áp dụng mẫu: $e', type: NoticeType.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _buildSampleReviewText(String brandName) {
    if (_previewSelectedKeywords.isEmpty) {
      return 'Trải nghiệm tại $brandName rất hài lòng! Dịch vụ chu đáo, chất lượng vượt mong đợi.';
    }
    final joined = _previewSelectedKeywords.join(', ');
    return 'Trải nghiệm tại $brandName rất tuyệt vời! Điểm cộng lớn là $joined. Chắc chắn sẽ tiếp tục ủng hộ!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final business = widget.session.business;
    final brandName = business?.brandName ?? 'Maison Coffee & Bistro';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(35, 24, 35, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh chuyển Tab Sub-nav
            _FunnelTabBar(currentPath: '/funnel/keywords'),
            const SizedBox(height: 20),

            // Tiêu đề trang
            Text('Cài đặt phễu: Từ khóa SEO & Ngưỡng phân luồng', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Tùy chỉnh ngưỡng chuyển tiếp khách hài lòng và bộ từ khóa gợi ý để tối ưu thứ hạng Google Maps.',
              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),

            if (_bannerNotice != null) ...[
              NoticeBanner(
                message: _bannerNotice!.text,
                type: _bannerNotice!.type,
                action: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _bannerNotice = null),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              NoticeBanner(
                message: _errorMessage!,
                type: NoticeType.error,
                action: TextButton(onPressed: _loadData, child: const Text('Thử lại')),
              )
            else ...[
              // PHẦN 1: NGƯỠNG PHÂN LUỒNG CẢM XÚC
              _buildRoutingRulesSection(context),

              const SizedBox(height: 32),

              // PHẦN 2: BỘ TỪ KHÓA GỢI Ý SEO
              _buildKeywordsSection(context, brandName),

              const SizedBox(height: 32),

              // PHẦN 3: XEM TRƯỚC TRỰC QUAN MÀN KHÁCH HÀNG (M1-02)
              _buildLivePreviewSection(context, brandName),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoutingRulesSection(BuildContext context) {
    final theme = Theme.of(context);
    final rule = _routingRule ?? RoutingRuleModel.defaults(_businessId ?? '');
    final currentMin = rule.satisfiedMinScore;
    final publicEnabled = rule.publicReviewEnabled;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: context.colors.secondary),
              const SizedBox(width: 8),
              Text('1. Ngưỡng điểm phân luồng cảm xúc (Routing Rules)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Quyết định mức đánh giá sao nào sẽ được mời đăng công khai lên Google Maps và mức nào chuyển tới form góp ý riêng tư.',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Lựa chọn ngưỡng sao
          const Text('Ngưỡng tính là Khách hài lòng:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _RoutingChoiceCard(
                title: '4 – 5 sao (Khuyên dùng)',
                description: '4-5 sao → Google Maps\n1-3 sao → Form góp ý nội bộ',
                selected: currentMin == 4,
                onTap: _canEdit ? () => _saveRoutingRule(minScore: 4, publicEnabled: publicEnabled) : null,
              ),
              _RoutingChoiceCard(
                title: 'Chỉ 5 sao (Khắt khe)',
                description: 'Chỉ 5 sao tuyệt đối → Google Maps\n1-4 sao → Form góp ý nội bộ',
                selected: currentMin == 5,
                onTap: _canEdit ? () => _saveRoutingRule(minScore: 5, publicEnabled: publicEnabled) : null,
              ),
              _RoutingChoiceCard(
                title: '3 – 5 sao (Mở rộng)',
                description: '3-5 sao → Google Maps\n1-2 sao → Form góp ý nội bộ',
                selected: currentMin == 3,
                onTap: _canEdit ? () => _saveRoutingRule(minScore: 3, publicEnabled: publicEnabled) : null,
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Tuân thủ Review Gating
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Lối đi đánh giá công khai cho khách 1–3 sao (Chống lọc đánh giá - Review Gating)',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                'Luôn hiển thị liên kết "Đăng đánh giá công khai lên Google" dưới form góp ý, tuân thủ 100% chính sách của Google Maps.',
                style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
              ),
              value: publicEnabled,
              onChanged: _canEdit
                  ? (val) => _saveRoutingRule(minScore: currentMin, publicEnabled: val)
                  : null,
            ),
          ),
          if (_savingRouting)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildKeywordsSection(BuildContext context, String brandName) {
    final theme = Theme.of(context);
    final activeCount = _keywords.where((k) => k.active).length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_important_outline, color: context.colors.secondary),
                  const SizedBox(width: 8),
                  Text('2. Bộ từ khóa gợi ý SEO theo ngành (Review Keywords)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Đang bật: $activeCount / ${_keywords.length}',
                  style: TextStyle(color: context.colors.secondary, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Khách hàng 4-5 sao sẽ thấy các thẻ chip từ khóa này trên màn hình M1-02. Khi chạm chọn, hệ thống tự động ghép vào câu đánh giá.',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Thanh chọn Template ngành
          Row(
            children: [
              const Text('Ngành nghề: ', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedIndustry,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'F&B', child: Text('Ẩm thực & Đồ uống (F&B)')),
                  DropdownMenuItem(value: 'NHA_KHOA', child: Text('Nha khoa & Y tế')),
                  DropdownMenuItem(value: 'SPA', child: Text('Spa & Thẩm mỹ viện')),
                  DropdownMenuItem(value: 'KHACH_SAN', child: Text('Khách sạn & Lưu trú')),
                  DropdownMenuItem(value: 'KHAC', child: Text('Dịch vụ tổng hợp')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedIndustry = val);
                },
              ),
              const Spacer(),
              OutlinedButton.icon(
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Áp dụng mẫu ngành này'),
                onPressed: _canEdit ? () => _confirmApplyTemplate(_selectedIndustry) : null,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ô thêm từ khóa mới
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newKeywordController,
                  decoration: InputDecoration(
                    hintText: 'Nhập từ khóa tích cực mới (ví dụ: Không gian thoáng mát, Bánh ngon...)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _addKeyword(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                icon: _addingKeyword
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add, size: 18),
                label: const Text('Thêm từ khóa'),
                onPressed: (_canEdit && !_addingKeyword) ? _addKeyword : null,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Danh sách chip từ khóa hiện có
          if (_keywords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('Chưa có từ khóa nào. Hãy thêm từ khóa hoặc áp dụng bộ mẫu theo ngành.',
                    style: TextStyle(color: context.colors.textSecondary)),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final kw in _keywords)
                  _KeywordChip(
                    keyword: kw,
                    canEdit: _canEdit,
                    onToggle: () => _toggleKeyword(kw),
                    onDelete: () => _deleteKeyword(kw),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLivePreviewSection(BuildContext context, String brandName) {
    final theme = Theme.of(context);
    final activeKeywords = _keywords.where((k) => k.active).toList();
    final sampleReview = _buildSampleReviewText(brandName);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.phone_iphone_rounded, color: context.colors.secondary),
              const SizedBox(width: 8),
              Text('3. Xem trước trải nghiệm khách hàng (Màn M1-02)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Khung dưới đây mô phỏng chính xác giao diện khách hàng sẽ thấy trên điện thoại sau khi chọn 4-5 sao.',
            style: TextStyle(color: context.colors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Khung mô phỏng màn hình điện thoại
          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars_rounded, color: Colors.amber, size: 40),
                  const SizedBox(height: 6),
                  Text('Cảm ơn bạn đã hài lòng!', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Chạm vào các từ khóa để gợi ý câu đánh giá:',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 12)),
                  const SizedBox(height: 14),

                  // Chip từ khóa tương tác
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final kw in activeKeywords)
                        FilterChip(
                          label: Text(kw.keyword, style: const TextStyle(fontSize: 12)),
                          selected: _previewSelectedKeywords.contains(kw.keyword),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _previewSelectedKeywords.add(kw.keyword);
                              } else {
                                _previewSelectedKeywords.remove(kw.keyword);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF2C1810).withValues(alpha: 0.15),
                          checkmarkColor: const Color(0xFF2C1810),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Khung câu review tự sinh
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      sampleReview,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nút hành động chính
                  Container(
                    width: double.infinity,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C1810),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Sao chép & Viết đánh giá trên Google',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelTabBar extends StatelessWidget {
  const _FunnelTabBar({required this.currentPath});

  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TabItem(
              label: 'Google Place ID (D3-05)',
              icon: Icons.place_outlined,
              selected: currentPath == '/funnel/google-place',
              onTap: () => context.go('/funnel/google-place'),
            ),
            Container(width: 1, height: 32, color: context.colors.border),
            _TabItem(
              label: 'Từ khóa SEO & Phân luồng (D3-07)',
              icon: Icons.tune_rounded,
              selected: currentPath == '/funnel/keywords',
              onTap: () => context.go('/funnel/keywords'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.accent : context.colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? context.colors.accent.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutingChoiceCard extends StatelessWidget {
  const _RoutingChoiceCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? context.colors.accent.withValues(alpha: 0.06) : Colors.transparent,
          border: Border.all(
            color: selected ? context.colors.accent : context.colors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: selected ? context.colors.accent : context.colors.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? context.colors.accent : context.colors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(description, style: TextStyle(color: context.colors.textSecondary, fontSize: 12, height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({
    required this.keyword,
    required this.canEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final ReviewKeywordModel keyword;
  final bool canEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: keyword.active ? context.colors.surface : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: keyword.active ? context.colors.accent.withValues(alpha: 0.4) : const Color(0xFFBDBDBD),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: canEdit ? onToggle : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  keyword.active ? Icons.check_circle : Icons.pause_circle_outline,
                  size: 16,
                  color: keyword.active ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  keyword.keyword,
                  style: TextStyle(
                    fontSize: 13,
                    color: keyword.active ? context.colors.textPrimary : const Color(0xFF757575),
                    decoration: keyword.active ? null : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(10),
              child: const Icon(Icons.close, size: 15, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }
}
