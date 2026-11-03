class RateResultModel {
  final String responseId;
  final String sessionId;
  final int starRating;
  final String sentimentGroup;
  final String targetScreen;
  final bool allowUrgentCall;
  final String message;
  final String hotline;

  const RateResultModel({
    required this.responseId,
    required this.sessionId,
    required this.starRating,
    required this.sentimentGroup,
    required this.targetScreen,
    required this.allowUrgentCall,
    required this.message,
    required this.hotline,
  });

  factory RateResultModel.fromJson(Map<String, dynamic> json) {
    return RateResultModel(
      responseId: json['responseId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      starRating: (json['starRating'] as num?)?.toInt() ?? 5,
      sentimentGroup: json['sentimentGroup'] as String? ?? 'POSITIVE',
      targetScreen: json['targetScreen'] as String? ?? 'M1-02',
      allowUrgentCall: json['allowUrgentCall'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      hotline: json['hotline'] as String? ?? '02838221122',
    );
  }
}

