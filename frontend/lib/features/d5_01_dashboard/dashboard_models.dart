class DashboardWeek {
  const DashboardWeek({
    required this.weekStart,
    required this.scanCount,
    this.satisfactionRate,
    required this.googleRedirectCount,
    this.googleReviewCount,
    this.googleAvgRating,
  });

  factory DashboardWeek.fromJson(Map<String, dynamic> json) => DashboardWeek(
        weekStart: DateTime.parse(json['weekStart'] as String),
        scanCount: json['scanCount'] as int? ?? 0,
        satisfactionRate: (json['satisfactionRate'] as num?)?.toDouble(),
        googleRedirectCount: json['googleRedirectCount'] as int? ?? 0,
        googleReviewCount: json['googleReviewCount'] as int?,
        googleAvgRating: (json['googleAvgRating'] as num?)?.toDouble(),
      );

  final DateTime weekStart;
  final int scanCount;
  final double? satisfactionRate;
  final int googleRedirectCount;
  final int? googleReviewCount;
  final double? googleAvgRating;
}

class DashboardData {
  const DashboardData({
    required this.scanCount,
    required this.ratedCount,
    this.satisfactionRate,
    required this.googleRedirectCount,
    this.googleReviewCount,
    this.googleAvgRating,
    required this.weekly,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
        scanCount: json['scanCount'] as int? ?? 0,
        ratedCount: json['ratedCount'] as int? ?? 0,
        satisfactionRate: (json['satisfactionRate'] as num?)?.toDouble(),
        googleRedirectCount: json['googleRedirectCount'] as int? ?? 0,
        googleReviewCount: json['googleReviewCount'] as int?,
        googleAvgRating: (json['googleAvgRating'] as num?)?.toDouble(),
        weekly: (json['weekly'] as List<dynamic>? ?? [])
            .map((week) => DashboardWeek.fromJson(week as Map<String, dynamic>))
            .toList(),
      );

  final int scanCount;
  final int ratedCount;
  final double? satisfactionRate;
  final int googleRedirectCount;
  final int? googleReviewCount;
  final double? googleAvgRating;
  final List<DashboardWeek> weekly;

  bool get isEmpty => scanCount == 0 && weekly.isEmpty;
}

/// Các khoảng thời gian có sẵn trên bộ lọc D5-01.
enum DashboardRange {
  weeks4('4 tuần gần nhất', 28),
  weeks8('8 tuần gần nhất', 56),
  weeks12('12 tuần gần nhất', 84);

  const DashboardRange(this.label, this.days);

  final String label;
  final int days;
}

/// Ngày dạng yyyy-MM-dd để gửi API.
String apiDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Số có dấu chấm ngăn cách hàng nghìn: 1.248.
String formatCount(int value) =>
    value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');

/// Phần trăm một chữ số thập phân, dùng dấu phẩy: 82,5%. Chưa có dữ liệu hiện dấu gạch.
String formatPercent(double? value) => value == null ? '—' : '${_decimal(value)}%';

String formatRating(double? value) => value == null ? '—' : '${_decimal(value)}★';

String _decimal(double value) {
  final text = value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
  return text.replaceAll('.', ',');
}

/// Nhãn tuần dd/MM trên biểu đồ.
String formatWeek(DateTime weekStart) =>
    '${weekStart.day.toString().padLeft(2, '0')}/${weekStart.month.toString().padLeft(2, '0')}';
