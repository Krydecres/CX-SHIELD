// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use, unnecessary_null_comparison
import 'dart:html' as html;
import 'voice_recognition_service_stub.dart';

export 'voice_recognition_service_stub.dart'
    show VoiceResultCallback, VoiceErrorCallback, VoiceEndCallback;

class VoiceRecognitionPlatform {
  static html.SpeechRecognition? _recognition;

  static bool startListening({
    required VoiceResultCallback onResult,
    required VoiceErrorCallback onError,
    required VoiceEndCallback onEnd,
  }) {
    if (!html.SpeechRecognition.supported) {
      onError('Trình duyệt không hỗ trợ Web Speech API. Vui lòng dùng Google Chrome.');
      return false;
    }

    try {
      if (_recognition != null) {
        try {
          _recognition!.abort();
        } catch (_) {}
      }

      final rec = html.SpeechRecognition();
      _recognition = rec;
      rec.lang = 'vi-VN';
      rec.continuous = true;
      rec.interimResults = true;

      rec.onResult.listen((html.SpeechRecognitionEvent event) {
        final results = event.results;
        if (results != null) {
          final sb = StringBuffer();
          for (final result in results) {
            if ((result.length ?? 0) > 0) {
              final alt = result.item(0);
              if (alt != null && alt.transcript != null) {
                sb.write(alt.transcript);
              }
            }
          }
          final fullText = sb.toString();
          if (fullText.isNotEmpty) {
            onResult(fullText);
          }
        }
      });

      rec.onError.listen((html.SpeechRecognitionError event) {
        String msg = event.error ?? 'Lỗi nhận diện giọng nói';
        if (msg == 'not-allowed') {
          msg = 'Vui lòng nhấn Cho Phép (Allow) quyền Micro trên trình duyệt để ghi âm.';
        } else if (msg == 'no-speech') {
          msg = 'Chưa nghe thấy giọng nói, vui lòng thử nói lại gần mic.';
        }
        onError(msg);
      });

      rec.onEnd.listen((_) {
        onEnd();
      });

      rec.start();
      return true;
    } catch (e) {
      onError('Không thể khởi động micro: $e');
      return false;
    }
  }

  static void stopListening() {
    if (_recognition != null) {
      try {
        _recognition!.stop();
      } catch (_) {}
    }
  }
}
