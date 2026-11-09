class RateResultModel {
  final String responseId;
  final String sessionId;
  final int starRating;
  final String sentimentGroup;
  final String targetScreen;
  final bool allowUrgentCall;
  final String message;
  final String hotline;
  final List<String> suggestedKeywords;
  final bool publicReviewEnabled;
  final String? reviewDirectUrl;
  final String? placeName;

  const RateResultModel({
    required this.responseId,
    required this.sessionId,
    required this.starRating,
    required this.sentimentGroup,
    required this.targetScreen,
    required this.allowUrgentCall,
    required this.message,
    required this.hotline,
    this.suggestedKeywords = const [],
    this.publicReviewEnabled = true,
    this.reviewDirectUrl,
    this.placeName,
  });

  factory RateResultModel.fromJson(Map<String, dynamic> json) {
    List<String> keywords = [];
    if (json['suggestedKeywords'] is List) {
      keywords = (json['suggestedKeywords'] as List).map((e) => e.toString()).toList();
    }
    return RateResultModel(
      responseId: json['responseId'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      starRating: (json['starRating'] as num?)?.toInt() ?? 5,
      sentimentGroup: json['sentimentGroup'] as String? ?? 'POSITIVE',
      targetScreen: json['targetScreen'] as String? ?? 'M1-02',
      allowUrgentCall: json['allowUrgentCall'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      hotline: json['hotline'] as String? ?? '02838221122',
      suggestedKeywords: keywords,
      publicReviewEnabled: json['publicReviewEnabled'] as bool? ?? true,
      reviewDirectUrl: json['reviewDirectUrl'] as String?,
      placeName: json['placeName'] as String?,
    );
  }
}
