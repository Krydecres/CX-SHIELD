import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/models/rate_result_model.dart';
import '../core/models/survey_init_model.dart';
import '../core/services/survey_api_service.dart';
import '../core/services/voice_recognition_service.dart';
import 'm1_01_rating_screen.dart';
import 'm1_05_urgent_call_screen.dart';
import 'm1_06_thank_you_screen.dart';

/// Màn hình M1-04: Phân luồng Khách Chưa Hài lòng (1-3 sao) tới Form Góp ý Nội bộ
/// User story 3: [E1.3] Phân luồng Khách Chưa Hài lòng tới Form Góp ý Nội bộ
/// Kèm E1.4: Lối đi đánh giá công khai (chống review gating)
/// Kèm E20.1: Ghi âm góp ý bằng giọng nói
class M104FeedbackScreen extends StatefulWidget {
  final SurveyInitModel surveyData;
  final RateResultModel rateResult;
  final SurveyApiService? apiService;
  final VoiceRecognitionService? voiceService;

  const M104FeedbackScreen({
    super.key,
    required this.surveyData,
    required this.rateResult,
    this.apiService,
    this.voiceService,
  });

  @override
  State<M104FeedbackScreen> createState() => _M104FeedbackScreenState();
}

class _M104FeedbackScreenState extends State<M104FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  final _phoneController = TextEditingController();
  late final SurveyApiService _apiService;
  late final VoiceRecognitionService _voiceService;

  bool _consentToContact = true;
  bool _isRecording = false;
  bool _isSubmitting = false;

  // Regex kiểm tra số điện thoại Việt Nam chuẩn (10 chữ số, đầu 03, 05, 07, 08, 09 hoặc +84)
  static final RegExp _vnPhoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');

  // Danh sách chủ đề góp ý gợi ý (Feedback Topics - E1.3)
  List<Map<String, dynamic>> _topics = const [
    {'id': 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380001', 'name': 'Món ăn / Đồ uống'},
    {'id': 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380002', 'name': 'Thái độ phục vụ'},
    {'id': 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380003', 'name': 'Thời gian chờ đợi'},
    {'id': 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380004', 'name': 'Không gian & Vệ sinh'},
    {'id': 'e1eebc99-9c0b-4ef8-bb6d-6bb9bd380005', 'name': 'Giá cả & Hóa đơn'},
  ];
  final Set<String> _selectedTopics = {};

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? SurveyApiService();
    _voiceService = widget.voiceService ?? VoiceRecognitionService();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final loaded = await _apiService.getFeedbackTopics();
    if (mounted && loaded.isNotEmpty) {
      setState(() {
        _topics = loaded;
      });
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
  void dispose() {
    _voiceService.stopListening();
    _commentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _voiceService.stopListening();
      setState(() => _isRecording = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã dừng thu âm giọng nói.'),
          backgroundColor: Color(0xFF059669),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      final started = _voiceService.startListening(
        onResult: (text) {
          if (mounted) {
            setState(() {
              _commentController.text = text;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() => _isRecording = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: const Color(0xFFDC2626),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        onEnd: () {
          if (mounted) {
            setState(() => _isRecording = false);
          }
        },
      );

      if (started) {
        setState(() => _isRecording = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎙️ Đang nghe giọng nói của bạn... Hãy nói vào Micro!'),
            backgroundColor: Color(0xFFDC2626),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final comment = _commentController.text.trim();
    final phone = _phoneController.text.trim();

    final selectedIds = <String>[];
    for (final t in _topics) {
      final name = t['name']?.toString() ?? '';
      final id = t['id']?.toString() ?? '';
      if (_selectedTopics.contains(name) && id.isNotEmpty) {
        selectedIds.add(id);
      }
    }

    // Gửi dữ liệu lưu vào bảng feedbacks, feedback_topic_links và kích hoạt sự kiện E2.2
    await _apiService.submitFeedback(
      responseId: widget.rateResult.responseId,
      commentText: comment,
      customerPhone: phone.isNotEmpty ? phone : null,
      consentToContact: _consentToContact,
      isUrgentCallback: widget.rateResult.allowUrgentCall,
      topicIds: selectedIds.isNotEmpty ? selectedIds : null,
    );

    if (!mounted) return;

    // Chuyển sang màn cảm ơn M1-06 (tiêu chí hoàn thành)
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => M106ThankYouScreen(
          surveyData: widget.surveyData,
        ),
      ),
    );
  }

  /// User Story 4 (E1.4): Lối đi đánh giá công khai cho khách 1–3 sao (Chống review gating)
  /// Không bắt buộc điền form, mở trực tiếp trang Google Maps chính thức của cơ sở
  Future<void> _openPublicGoogleReview() async {
    // 1. Ghi nhận bypass và lấy link Google Maps chính thức của cơ sở
    final reviewUrl = await _apiService.recordPublicBypass(
      responseId: widget.rateResult.responseId,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở trang đánh giá chính thức của ${widget.surveyData.businessName}...'),
        backgroundColor: const Color(0xFF1E3A8A),
        duration: const Duration(seconds: 3),
      ),
    );

    // 2. Mở đúng liên kết Google Maps của cơ sở
    final uri = Uri.parse(reviewUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = widget.rateResult.starRating;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _handleBack,
            tooltip: 'Quay lại khảo sát',
          ),
          title: const Text(
            'M1-04: Góp ý riêng cho cơ sở',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Banner thấu hiểu & lời xin lỗi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🙏', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chúng tôi thành thật xin lỗi!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Bạn đã đánh giá $stars sao. Ban Quản lý ${widget.surveyData.businessName} sẽ tiếp nhận trực tiếp phản ánh này để giải quyết thỏa đáng.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade800,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Lối tắt khẩn cấp cho khách 1 sao (Epic 26.1: M1-05)
                    if (widget.rateResult.allowUrgentCall || stars == 1) ...[
                      const SizedBox(height: 14),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => M105UrgentCallScreen(
                                surveyData: widget.surveyData,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.flash_on_rounded, color: Color(0xFFD97706), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Cần giải quyết nóng tại bàn? Bấm vào đây để gọi Quản lý',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF92400E),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Color(0xFFD97706)),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // 2. Chọn chủ đề góp ý nhanh (Feedback Topics)
                    const Text(
                      'Bạn chưa hài lòng về vấn đề gì?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _topics.map((topicItem) {
                        final topicName = topicItem['name']?.toString() ?? '';
                        final isSelected = _selectedTopics.contains(topicName);
                        return FilterChip(
                          label: Text(
                            topicName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF4B5563),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFFDBEAFE),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTopics.add(topicName);
                              } else {
                                _selectedTopics.remove(topicName);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // 3. Form góp ý: Nội dung (Bắt buộc, 3 - 1000 ký tự)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Chi tiết góp ý',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' *',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                        Text(
                          '${_commentController.text.length}/1000',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      maxLength: 1000,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập nội dung góp ý để cơ sở cải thiện';
                        }
                        if (value.trim().length < 3) {
                          return 'Nội dung góp ý quá ngắn (tối thiểu 3 ký tự)';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung chia sẻ về món ăn, nhân viên hoặc không gian...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Nút thu âm giọng nói trực tiếp qua Micro (Epic 20: Voice Feedback - Speech to Text)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _isRecording ? Colors.red.shade700 : const Color(0xFF374151),
                            backgroundColor: _isRecording ? const Color(0xFFFEF2F2) : Colors.white,
                            side: BorderSide(
                              color: _isRecording ? Colors.red : const Color(0xFFD1D5DB),
                              width: _isRecording ? 1.8 : 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _toggleRecording,
                          icon: Icon(
                            _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                            size: 20,
                            color: _isRecording ? Colors.red : const Color(0xFF2563EB),
                          ),
                          label: Text(
                            _isRecording ? '🔴 Đang thu âm... Bấm để dừng' : 'Nói vào Micro (Chuyển giọng nói thành chữ)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _isRecording ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (_isRecording) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD97706)),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đang nghe giọng nói của bạn (tiếng Việt)... Hãy nói vào mic, chữ sẽ tự động hiện lên ô trên!',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 4. Form góp ý: SĐT liên hệ (Không bắt buộc, nhưng kiểm tra đúng định dạng VN)
                    const Text(
                      'Số điện thoại liên hệ (không bắt buộc)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null; // Không bắt buộc
                        }
                        final cleanPhone = value.trim().replaceAll(RegExp(r'[\s.-]'), '');
                        if (!_vnPhoneRegex.hasMatch(cleanPhone)) {
                          return 'Số điện thoại không đúng định dạng VN (ví dụ: 0901234567)';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Nhập số điện thoại để nhận phản hồi',
                        prefixIcon: const Icon(Icons.phone_rounded, size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // 5. Ô đồng ý cho cơ sở liên hệ (Consent checkbox)
                    CheckboxListTile(
                      value: _consentToContact,
                      onChanged: (val) {
                        setState(() => _consentToContact = val ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      dense: true,
                      title: const Text(
                        'Tôi đồng ý cho cơ sở liên hệ lại để giải quyết và chăm sóc dịch vụ.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF374151)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Nút gửi góp ý riêng
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Gửi Góp Ý Riêng Tới Quản Lý',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 7. User Story 4 (E1.4): Lối đi đánh giá công khai cho khách 1–3 sao (Chống lọc đánh giá – review gating)
                    // Luôn hiển thị dưới form góp ý, không ẩn, không bắt buộc điền form trước
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Bạn muốn chia sẻ trải nghiệm công khai?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Cơ sở luôn tôn trọng quyền tự do đánh giá của bạn theo chính sách minh bạch của Google.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3),
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: _openPublicGoogleReview,
                            icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFF1E3A8A)),
                            label: const Text(
                              'Đăng đánh giá công khai lên Google',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shield_outlined, size: 14, color: Color(0xFF9CA3AF)),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Bảo vệ bởi reCAPTCHA ẩn • Tuân thủ chính sách Google Review',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                                ),
                              ),
                            ],
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
      ),
    ),
  );
}
}
