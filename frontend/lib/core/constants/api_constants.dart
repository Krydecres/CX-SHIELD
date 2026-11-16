class ApiConstants {
  // Cho phép cấu hình qua môi trường hoặc mặc định localhost:8080
  static const String baseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const String surveyQrEndpoint = '$baseUrl/surveys/qr';
  static const String surveyRateEndpoint = '$baseUrl/surveys/rate';
  static const String feedbackEndpoint = '$baseUrl/feedbacks';
  static const String googleRedirectEndpoint = '$baseUrl/surveys/google-redirect';
  static const String publicReviewBypassEndpoint = '$baseUrl/surveys/public-review';
  static const Duration timeout = Duration(milliseconds: 3000);
}
