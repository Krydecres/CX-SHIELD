import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/models/rate_result_model.dart';
import '../core/models/survey_init_model.dart';

/// Màn hình M1-02: Phân luồng khách hài lòng (4-5 sao) sang Google Maps + Câu gợi ý tự copy
class M102GoogleReviewScreen extends StatefulWidget {
  final SurveyInitModel surveyData;
  final RateResultModel rateResult;

  const M102GoogleReviewScreen({
    super.key,
    required this.surveyData,
    required this.rateResult,
  });

  @override
  State<M102GoogleReviewScreen> createState() => _M102GoogleReviewScreenState();
}

class _M102GoogleReviewScreenState extends State<M102GoogleReviewScreen> {
  bool _isCopied = false;
  final String _suggestedReview =
      'Đồ uống tại Maison Coffee & Bistro rất ngon và chuẩn vị, không gian quán ấm cúng, sang trọng. Nhân viên phục vụ rất chu đáo và nhiệt tình!';

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

  void _openGoogleReview() {
    // Tự động copy gợi ý để khách chỉ việc dán
    if (!_isCopied) {
      Clipboard.setData(ClipboardData(text: _suggestedReview));
    }

    // Hiển thị dialog thông báo chuyển tiếp Google Maps
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('Mở Google Maps', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Câu nhận xét đã được tự động sao chép. Bạn chỉ cần nhấn giữ và chọn "Dán" khi cửa sổ đánh giá Google mở ra!',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đã hiểu & Tiếp tục'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('M1-02: Đánh giá Google Maps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
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

                  Text(
                    'Cảm ơn bạn đã chấm ${widget.rateResult.starRating} sao!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sự hài lòng của bạn là niềm vinh hạnh của ${widget.surveyData.businessName}. Hãy dành 10 giây giúp chúng tôi lan tỏa trên Google Maps nhé!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // Box câu gợi ý tích cực
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, size: 16, color: Color(0xFFD97706)),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Gợi ý nhận xét (tự động copy)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFB45309),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _copyToClipboard,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: Icon(
                                _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                                size: 14,
                                color: const Color(0xFF059669),
                              ),
                              label: Text(
                                _isCopied ? 'Đã chép' : 'Sao chép',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
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
                  const SizedBox(height: 16),

                  // Nút quay lại khảo sát
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('← Trở lại khảo sát'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
