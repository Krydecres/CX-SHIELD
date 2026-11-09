class ReviewKeywordModel {
  final String id;
  final String businessId;
  final String industry;
  final String keyword;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReviewKeywordModel({
    required this.id,
    required this.businessId,
    required this.industry,
    required this.keyword,
    required this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewKeywordModel.fromJson(Map<String, dynamic> json) {
    return ReviewKeywordModel(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      industry: json['industry'] as String? ?? 'F&B',
      keyword: json['keyword'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  ReviewKeywordModel copyWith({
    String? keyword,
    bool? active,
    String? industry,
  }) {
    return ReviewKeywordModel(
      id: id,
      businessId: businessId,
      industry: industry ?? this.industry,
      keyword: keyword ?? this.keyword,
      active: active ?? this.active,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class RoutingRuleModel {
  final String id;
  final String businessId;
  final int satisfiedMinScore;
  final int satisfiedMaxScore;
  final bool publicReviewEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoutingRuleModel({
    required this.id,
    required this.businessId,
    required this.satisfiedMinScore,
    required this.satisfiedMaxScore,
    required this.publicReviewEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory RoutingRuleModel.fromJson(Map<String, dynamic> json) {
    return RoutingRuleModel(
      id: json['id'] as String? ?? '',
      businessId: json['businessId'] as String? ?? '',
      satisfiedMinScore: (json['satisfiedMinScore'] as num?)?.toInt() ?? 4,
      satisfiedMaxScore: (json['satisfiedMaxScore'] as num?)?.toInt() ?? 5,
      publicReviewEnabled: json['publicReviewEnabled'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  factory RoutingRuleModel.defaults(String businessId) {
    return RoutingRuleModel(
      id: '',
      businessId: businessId,
      satisfiedMinScore: 4,
      satisfiedMaxScore: 5,
      publicReviewEnabled: true,
    );
  }

  RoutingRuleModel copyWith({
    int? satisfiedMinScore,
    int? satisfiedMaxScore,
    bool? publicReviewEnabled,
  }) {
    return RoutingRuleModel(
      id: id,
      businessId: businessId,
      satisfiedMinScore: satisfiedMinScore ?? this.satisfiedMinScore,
      satisfiedMaxScore: satisfiedMaxScore ?? this.satisfiedMaxScore,
      publicReviewEnabled: publicReviewEnabled ?? this.publicReviewEnabled,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class IndustryTemplateModel {
  final String industry;
  final String displayName;
  final List<String> keywords;

  const IndustryTemplateModel({
    required this.industry,
    required this.displayName,
    required this.keywords,
  });

  factory IndustryTemplateModel.fromJson(Map<String, dynamic> json) {
    return IndustryTemplateModel(
      industry: json['industry'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
