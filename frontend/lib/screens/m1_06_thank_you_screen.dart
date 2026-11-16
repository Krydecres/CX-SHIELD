import 'package:flutter/material.dart';
import '../core/models/survey_init_model.dart';
import 'm1_01_rating_screen.dart';

/// Màn hình M1-06: Màn cảm ơn (Kết thúc khảo sát)
/// User story 3: [E1.3] Phân luồng Khách Chưa Hài lòng tới Form Góp ý Nội bộ
/// Nối tới: Nút "Nhận ưu đãi" -> M2-01 (Màn hình nhận Voucher qua SMS/Zalo)
class M106ThankYouScreen extends StatelessWidget {
  final SurveyInitModel surveyData;

  const M106ThankYouScreen({
    super.key,
    required this.surveyData,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => M101RatingScreen(qrCode: surveyData.qrCode),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon thành công & tri ân
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 52,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tên thương hiệu
                  Text(
                    surveyData.businessName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Tiêu đề cảm ơn
                  const Text(
                    'Cảm ơn bạn đã góp ý!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nội dung ghi nhận
                  const Text(
                    'Phản ánh của bạn đã được chuyển thẳng tới Quản lý cơ sở để khắc phục ngay. Mọi đóng góp đều là động lực để chúng tôi phục vụ bạn tốt hơn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Card quà tri ân (User Story E6.1 / E9.1: Nút "Nhận ưu đãi" -> M2-01)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_giftcard_rounded, color: Color(0xFFD97706), size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Quà tri ân từ cơ sở',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Maison Coffee & Bistro xin gửi tặng bạn mã ưu đãi đặc biệt cho lần trải nghiệm tiếp theo thay lời cảm ơn chân thành.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Nút "Nhận ưu đãi" (Wireframe M1-06 nối tới M2-01)
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 1,
                            ),
                            onPressed: () {
                              // Chuyển sang màn hình M2-01 (Nhận ưu đãi qua SMS / Zalo)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đang mở màn hình M2-01: Nhận ưu đãi qua SMS / Zalo...'),
                                  backgroundColor: Color(0xFF1E3A8A),
                                ),
                              );
                            },
                            icon: const Icon(Icons.confirmation_number_outlined, size: 20),
                            label: const Text(
                              'Nhận Ưu Đãi Tri Ân (M2-01)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Nút hoàn tất / quay về
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => M101RatingScreen(qrCode: surveyData.qrCode),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      'Hoàn tất khảo sát',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'CX-SHIELD • Review Funnel',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
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

