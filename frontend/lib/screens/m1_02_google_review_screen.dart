import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/models/rate_result_model.dart';
import '../core/models/survey_init_model.dart';
import '../core/services/survey_api_service.dart';
import 'm1_01_rating_screen.dart';

/// Màn hình M1-02: Phân luồng khách hài lòng (4-5 sao) sang Google Maps + Câu gợi ý tự copy
/// User story 2 [E1.2] & [E4.3]: Áp dụng từ khóa SEO động, tự copy gợi ý, mở Google Maps, ghi nhận redirect_clicked_at
class M102GoogleReviewScreen extends StatefulWidget {
  final SurveyInitModel surveyData;
  final RateResultModel rateResult;
  final SurveyApiService? apiService;

  const M102GoogleReviewScreen({
    super.key,
    required this.surveyData,
    required this.rateResult,
    this.apiService,
  });

  @override
  State<M102GoogleReviewScreen> createState() => _M102GoogleReviewScreenState();
}

class _M102GoogleReviewScreenState extends State<M102GoogleReviewScreen> {
  bool _isCopied = false;
  late final List<String> _availableKeywords;
  final Set<String> _selectedKeywords = {};
  late final SurveyApiService _apiService = widget.apiService ?? SurveyApiService();

  @override
  void initState() {
    super.initState();
    // Lấy từ khóa động từ RateResult (cấu hình D3-07) hoặc fallback bộ từ khóa chuẩn ngành
    if (widget.rateResult.suggestedKeywords.isNotEmpty) {
      _availableKeywords = List.from(widget.rateResult.suggestedKeywords);
    } else {
      _availableKeywords = [
        'Cà phê đậm đà ngon',
        'Không gian ấm cúng, view đẹp',
        'Nhân viên nhiệt tình, chu đáo',
        'Phục vụ nhanh chóng',
      ];
    }

    // Chọn sẵn 2 từ khóa đầu tiên làm gợi ý mặc định
    for (int i = 0; i < 2 && i < _availableKeywords.length; i++) {
      _selectedKeywords.add(_availableKeywords[i]);
    }
  }

  /// Sinh câu gợi ý tích cực dựa trên bộ từ khóa đã chọn
  String get _suggestedReview {
    final brand = widget.surveyData.businessName;
    if (_selectedKeywords.isEmpty) {
      return 'Trải nghiệm tại $brand rất hài lòng! Dịch vụ chu đáo, chất lượng vượt mong đợi.';
    }
    final joined = _selectedKeywords.join(', ');
    return 'Trải nghiệm tại $brand rất tuyệt vời! Điểm cộng lớn: $joined. Sẽ quay lại ủng hộ!';
  }

  /// Copy câu gợi ý vào bộ nhớ tạm
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _suggestedReview));
    setState(() => _isCopied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép câu gợi ý vào bộ nhớ tạm!'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  /// Mở trang viết đánh giá Google Maps của cơ sở
  /// Tiêu chí hoàn thành:
  /// 1. Tự động copy gợi ý vào clipboard
  /// 2. Ghi nhận lượt bấm chuyển sang Google (redirect_clicked_at)
  /// 3. Mở link Google Maps tạo từ Place ID (không chọn sẵn sao, không điền sẵn chữ)
  Future<void> _openGoogleReview() async {
    // 1. Tự động copy câu gợi ý
    await Clipboard.setData(ClipboardData(text: _suggestedReview));
    if (mounted) setState(() => _isCopied = true);

    // 2. Ghi nhận lượt bấm chuyển sang Google (redirect_clicked_at)
    String targetUrl = widget.rateResult.reviewDirectUrl ?? '';
    try {
      final serverUrl = await _apiService.recordGoogleRedirect(
        responseId: widget.rateResult.responseId,
      );
      if (serverUrl.isNotEmpty) {
        targetUrl = serverUrl;
      }
    } catch (_) {
      // Fallback nếu lỗi kết nối
    }

    if (targetUrl.isEmpty) {
      targetUrl = 'https://search.google.com/local/writereview?placeid=ChIJ1234567890abcdef';
    }

    if (!mounted) return;

    // 3. Thông báo phản hồi trực quan
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép nhận xét! Đang mở trang đánh giá của ${widget.surveyData.businessName}...'),
        backgroundColor: const Color(0xFF047857),
        duration: const Duration(seconds: 3),
      ),
    );

    // 4. Mở liên kết đánh giá chính thức
    final uri = Uri.parse(targetUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => M101RatingScreen(qrCode: widget.surveyData.qrCode),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text('M1-02: Đánh giá Google Maps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
            tooltip: 'Trở lại khảo sát',
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon chúc mừng
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('🎉', style: TextStyle(fontSize: 34)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tiêu đề & Cảm ơn
                    Text(
                      widget.rateResult.starRating == 5
                          ? 'Cảm ơn bạn đã chấm 5 sao!'
                          : (widget.rateResult.message.isNotEmpty
                              ? widget.rateResult.message
                              : 'Cảm ơn bạn đã hài lòng!'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đánh giá của bạn trên Google Maps giúp ${widget.surveyData.businessName} lan tỏa dịch vụ tốt hơn!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // E4.3: Chọn từ khóa gợi ý SEO
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chạm chọn từ khóa bạn ấn tượng nhất:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF374151)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final kw in _availableKeywords)
                          FilterChip(
                            label: Text(kw, style: const TextStyle(fontSize: 12)),
                            selected: _selectedKeywords.contains(kw),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedKeywords.add(kw);
                                } else {
                                  _selectedKeywords.remove(kw);
                                }
                              });
                            },
                            selectedColor: const Color(0xFF1E3A8A).withValues(alpha: 0.15),
                            checkmarkColor: const Color(0xFF1E3A8A),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Box gợi ý câu đánh giá tự động copy
                    InkWell(
                      onTap: _copyToClipboard,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome, color: Color(0xFFD97706), size: 18),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Gợi ý nhận xét (bấm để sao chép):',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                                    color: _isCopied ? const Color(0xFF059669) : const Color(0xFF1E3A8A),
                                    size: 20,
                                  ),
                                  onPressed: _copyToClipboard,
                                  tooltip: 'Sao chép gợi ý',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _suggestedReview,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF374151),
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nút mở Google Maps
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _openGoogleReview,
                        icon: const Icon(Icons.rate_review_rounded, size: 20),
                        label: const Text(
                          'Đăng Đánh Giá Lên Google Maps',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Huy hiệu tuân thủ chính sách Google Review
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF6B7280)),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Tuân thủ chính sách Google: Đánh giá tự nguyện, không can thiệp số sao.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Nút quay lại khảo sát (đã fix BUG-SCRUM-189-01 an toàn)
                    TextButton(
                      onPressed: _handleBack,
                      child: const Text('← Trở lại khảo sát'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
