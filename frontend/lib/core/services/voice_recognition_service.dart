import 'voice_recognition_service_stub.dart'
    if (dart.library.html) 'voice_recognition_service_web.dart'
    as platform;

typedef VoiceResultCallback = void Function(String text);
typedef VoiceErrorCallback = void Function(String error);
typedef VoiceEndCallback = void Function();

class VoiceRecognitionService {
  bool _isListening = false;
  bool get isListening => _isListening;

  /// Bắt đầu lắng nghe giọng nói trực tiếp qua Micro (tiếng Việt vi-VN)
  bool startListening({
    required VoiceResultCallback onResult,
    required VoiceErrorCallback onError,
    required VoiceEndCallback onEnd,
  }) {
    _isListening = true;
    final success = platform.VoiceRecognitionPlatform.startListening(
      onResult: onResult,
      onError: (err) {
        _isListening = false;
        onError(err);
      },
      onEnd: () {
        _isListening = false;
        onEnd();
      },
    );
    if (!success) {
      _isListening = false;
    }
    return success;
  }

  /// Dừng lắng nghe
  void stopListening() {
    _isListening = false;
    platform.VoiceRecognitionPlatform.stopListening();
  }
}
