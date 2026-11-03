typedef VoiceResultCallback = void Function(String text);
typedef VoiceErrorCallback = void Function(String error);
typedef VoiceEndCallback = void Function();

class VoiceRecognitionPlatform {
  static bool startListening({
    required VoiceResultCallback onResult,
    required VoiceErrorCallback onError,
    required VoiceEndCallback onEnd,
  }) {
    // Mô phỏng trên môi trường test / VM
    Future.delayed(const Duration(milliseconds: 100), () {
      onResult('Món ăn phục vụ hơi chậm, cần cải thiện.');
      onEnd();
    });
    return true;
  }

  static void stopListening() {}
}
