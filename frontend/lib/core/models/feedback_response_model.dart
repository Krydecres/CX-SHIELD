class FeedbackResponseModel {
  final String feedbackId;
  final String responseId;
  final String status;
  final String targetScreen;
  final String message;
  final String submittedAt;
  final List<String> topicIds;
  final List<String> topicNames;

  const FeedbackResponseModel({
    required this.feedbackId,
    required this.responseId,
    required this.status,
    required this.targetScreen,
    required this.message,
    required this.submittedAt,
    this.topicIds = const [],
    this.topicNames = const [],
  });

  factory FeedbackResponseModel.fromJson(Map<String, dynamic> json) {
    List<String> tIds = [];
    if (json['topicIds'] is List) {
      tIds = (json['topicIds'] as List).map((e) => e.toString()).toList();
    }
    List<String> tNames = [];
    if (json['topicNames'] is List) {
      tNames = (json['topicNames'] as List).map((e) => e.toString()).toList();
    }
    return FeedbackResponseModel(
      feedbackId: json['feedbackId'] as String? ?? '',
      responseId: json['responseId'] as String? ?? '',
      status: json['status'] as String? ?? 'NEW',
      targetScreen: json['targetScreen'] as String? ?? 'M1-06',
      message: json['message'] as String? ?? '',
      submittedAt: json['submittedAt'] as String? ?? '',
      topicIds: tIds,
      topicNames: tNames,
    );
  }
}

