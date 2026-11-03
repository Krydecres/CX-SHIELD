import 'package:flutter/material.dart';
import 'screens/m1_01_rating_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CxShieldApp());
}

class CxShieldApp extends StatelessWidget {
  const CxShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tự động nhận diện mã QR từ query parameter của URL (ví dụ: ?qr=MC-B04 hoặc ?code=MC-B04)
    String qrCode = 'MC-B04';
    try {
      final uri = Uri.base;
      qrCode = uri.queryParameters['qr'] ??
          uri.queryParameters['code'] ??
          'MC-B04';
    } catch (_) {}

    return MaterialApp(
      title: 'Maison Coffee & Bistro - Khảo sát',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C1810),
          primary: const Color(0xFF2C1810),
        ),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: M101RatingScreen(qrCode: qrCode),
    );
  }
}
