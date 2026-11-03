import 'package:flutter/material.dart';
import '../core/models/survey_init_model.dart';
import '../core/services/survey_api_service.dart';
import 'm1_02_google_review_screen.dart';
import 'm1_04_feedback_screen.dart';
import 'm1_05_urgent_call_screen.dart';

/// Màn hình M1-01: Màn chọn sao (Khảo sát cảm xúc siêu tốc < 1s)
/// User story 1: [E1.1] Màn hình Khảo sát Cảm xúc Siêu tốc (<1s)
class M101RatingScreen extends StatefulWidget {
  final String qrCode;
  final SurveyApiService? apiService;

  const M101RatingScreen({
    super.key,
    this.qrCode = 'MC-B04',
    this.apiService,
  });

  @override
  State<M101RatingScreen> createState() => _M101RatingScreenState();
}

class _M101RatingScreenState extends State<M101RatingScreen> {
  late final SurveyApiService _apiService;
  late SurveyInitModel _surveyData;
  bool _isSubmitting = false;
  int? _hoveredStar;
  int? _selectedStar;

  // Nhãn cảm xúc tương ứng từng mức sao (1-5)
  final List<Map<String, String>> _starLabels = const [
    {'label': 'Rất thất vọng', 'emoji': '😡'},
    {'label': 'Chưa hài lòng', 'emoji': '🙁'},
    {'label': 'Bình thường', 'emoji': '😐'},
    {'label': 'Hài lòng', 'emoji': '😊'},
    {'label': 'Tuyệt vời', 'emoji': '🤩'},
  ];

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? SurveyApiService();
    // Khởi tạo ngay fallback để hiển thị tức thì (<1s)
    _surveyData = SurveyInitModel.fallback(widget.qrCode);
    _loadSurveyData();
  }

  Future<void> _loadSurveyData() async {
    final data = await _apiService.initSurvey(widget.qrCode);
    if (mounted) {
      setState(() {
        _surveyData = data;
      });
    }
  }

  Future<void> _handleRating(int stars) async {
    if (_isSubmitting) return;

    setState(() {
      _selectedStar = stars;
      _isSubmitting = true;
    });

    // Gọi API ghi nhận kết quả và phân luồng cảm xúc
    final result = await _apiService.submitRating(
      sessionId: _surveyData.sessionId,
      starRating: stars,
    );

    if (!mounted) return;

    // Phân luồng điều hướng:
    // 4–5 sao -> M1-02 (Google Maps)
    // 1–3 sao -> M1-04 (Form góp ý nội bộ)
    // 1 sao có thêm nút/liên kết M1-05 (Hotline khẩn cấp)
    if (stars >= 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => M102GoogleReviewScreen(
            surveyData: _surveyData,
            rateResult: result,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => M104FeedbackScreen(
            surveyData: _surveyData,
            rateResult: result,
          ),
        ),
      );
    }
  }

  Color _parsePrimaryColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF2C1810);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _parsePrimaryColor(_surveyData.primaryColor);
    final activeStar = _hoveredStar ?? _selectedStar ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),

                  // 1. Brand Logo / Avatar
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.coffee_rounded,
                        size: 38,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Brand Name
                  Text(
                    _surveyData.businessName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. Branch & Table Badge (Nhận diện chi nhánh / bàn từ QR)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_rounded, size: 14, color: primaryColor),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${_surveyData.branchName} • ${_surveyData.tableOrAreaCode}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 4. Main Survey Card (M1-01: Màn chọn sao)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Trải nghiệm của bạn hôm nay thế nào?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chạm vào số sao để đánh giá ngay (không cần đăng nhập)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Emoji & Label cảm xúc linh hoạt theo tương tác
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: activeStar > 0
                              ? Container(
                                  key: ValueKey(activeStar),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: activeStar >= 4
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _starLabels[activeStar - 1]['emoji']!,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _starLabels[activeStar - 1]['label']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: activeStar >= 4
                                              ? const Color(0xFF065F46)
                                              : const Color(0xFF991B1B),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(
                                  key: ValueKey(0),
                                  height: 38,
                                  child: Center(
                                    child: Text(
                                      'Chọn từ 1 đến 5 sao',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // 5 Ngôi sao lớn (1 - 5 sao)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isFilled = activeStar >= starValue;

                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) {
                                setState(() => _hoveredStar = starValue);
                              },
                              onExit: (_) {
                                setState(() => _hoveredStar = null);
                              },
                              child: GestureDetector(
                                onTap: () => _handleRating(starValue),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: AnimatedScale(
                                    scale: isFilled ? 1.15 : 1.0,
                                    duration: const Duration(milliseconds: 150),
                                    child: Icon(
                                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                                      size: 48,
                                      color: isFilled
                                          ? const Color(0xFFF59E0B)
                                          : const Color(0xFFD1D5DB),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        if (_isSubmitting) ...[
                          const SizedBox(height: 24),
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Đang chuyển tiếp...',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Lối đi khẩn cấp trực tiếp cho khách tại bàn (M1-05 link)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => M105UrgentCallScreen(
                            surveyData: _surveyData,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: Color(0xFFDC2626)),
                    label: const Text(
                      'Cần hỗ trợ gấp tại bàn? Bấm vào đây',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer thương hiệu
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: Color(0xFF9CA3AF)),
                      SizedBox(width: 4),
                      Text(
                        'CX-SHIELD • Review Funnel',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
