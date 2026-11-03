import 'package:flutter/material.dart';
import '../core/models/survey_init_model.dart';

/// Màn hình M1-05: Màn 1 sao: hotline khẩn & nút yêu cầu quản lý gọi lại (Epic 26.1)
class M105UrgentCallScreen extends StatefulWidget {
  final SurveyInitModel surveyData;

  const M105UrgentCallScreen({
    super.key,
    required this.surveyData,
  });

  @override
  State<M105UrgentCallScreen> createState() => _M105UrgentCallScreenState();
}

class _M105UrgentCallScreenState extends State<M105UrgentCallScreen> {
  final _phoneController = TextEditingController();
  bool _isRequested = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _requestCallback() {
    setState(() => _isRequested = true);
  }

  @override
  Widget build(BuildContext context) {
    final hotline = widget.surveyData.hotline ?? '02838221122';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('M1-05: Hỗ trợ khẩn cấp tại bàn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
              child: _isRequested
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Icon(Icons.ring_volume_rounded, size: 70, color: Color(0xFF059669)),
                        const SizedBox(height: 16),
                        const Text(
                          'Đã gửi yêu cầu khẩn cấp!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quản lý ca trực tại ${widget.surveyData.branchName} đang di chuyển tới ${widget.surveyData.tableOrAreaCode} hoặc gọi ngay cho bạn trong ít phút.',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Đóng'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEF2F2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.support_agent_rounded, size: 40, color: Color(0xFFDC2626)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Giải quyết ngay trước khi rời đi',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đừng vội thất vọng ra về! Quản lý ${widget.surveyData.businessName} luôn túc trực để hỗ trợ và xử lý trực tiếp mọi sự cố tại bàn của bạn.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // Hotline trực tiếp
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            children: [
                              const Text('Hotline khẩn cấp của Quản lý chi nhánh', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              Text(
                                hotline,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDC2626),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đang kết nối cuộc gọi tới Hotline: $hotline')),
                                  );
                                },
                                icon: const Icon(Icons.call_rounded, size: 18),
                                label: const Text('Bấm Gọi Trực Tiếp Ngay'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        const Text('— HOẶC —', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),

                        // Form yêu cầu quản lý gọi lại
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Yêu cầu quản lý ra bàn hoặc gọi lại trong 5 phút:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Nhập số điện thoại của bạn',
                                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 18),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E3A8A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _requestCallback,
                                  child: const Text('Yêu Cầu Quản Lý Gặp / Gọi Lại Ngay'),
                                ),
                              ),
                            ],
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
}

