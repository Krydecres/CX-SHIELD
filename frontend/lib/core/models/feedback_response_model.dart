class FeedbackResponseModel {
  final String feedbackId;
  final String responseId;
  final String status;
  final String targetScreen;
  final String message;
  final String submittedAt;

  const FeedbackResponseModel({
    required this.feedbackId,
    required this.responseId,
    required this.status,
    required this.targetScreen,
    required this.message,
    required this.submittedAt,
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    return FeedbackResponseModel(
      feedbackId: json['feedbackId'] as String? ?? '',
      responseId: json['responseId'] as String? ?? '',
      status: json['status'] as String? ?? 'NEW',
      targetScreen: json['targetScreen'] as String? ?? 'M1-06',
      message: json['message'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
    );
  }
}

