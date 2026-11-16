import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'dashboard_models.dart';

/// Thẻ số liệu trên D5-01.
class MetricCard extends StatelessWidget {
  const MetricCard({super.key, required this.label, required this.value, this.note});

  final String label;
  final String value;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(note!, style: theme.textTheme.bodySmall?.copyWith(color: context.colors.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Phễu chuyển đổi: mỗi bước một thanh, độ dài theo tỷ lệ so với lượt quét.
class FunnelChart extends StatelessWidget {
  const FunnelChart({super.key, required this.steps});

  final List<FunnelStep> steps;

  @override
  Widget build(BuildContext context) {
    final total = steps.isEmpty ? 0 : steps.first.count;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text(step.label, overflow: TextOverflow.ellipsis)),
                    Text(
                      '${formatCount(step.count)} · ${formatPercent(total == 0 ? null : step.count * 100 / total)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    key: ValueKey('funnel-${step.label}'),
                    value: total == 0 ? 0 : step.count / total,
                    minHeight: 10,
                    backgroundColor: context.colors.secondarySoft,
                    color: context.colors.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Biểu đồ cột lượt quét theo tuần; cột cao nhất chiếm hết chiều cao vùng vẽ.
class WeeklyBarChart extends StatelessWidget {
  const WeeklyBarChart({super.key, required this.weeks});

  static const double _plotHeight = 150;

  final List<DashboardWeek> weeks;

  @override
  Widget build(BuildContext context) {
    final highest = weeks.fold<int>(0, (max, week) => week.scanCount > max ? week.scanCount : max);
    return SizedBox(
      height: _plotHeight + 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final week in weeks)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(formatCount(week.scanCount), style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Container(
                    key: ValueKey('bar-${apiDate(week.weekStart)}'),
                    height: highest == 0 ? 2 : (_plotHeight * week.scanCount / highest).clamp(2, _plotHeight),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(color: context.colors.secondary, borderRadius: BorderRadius.circular(3)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatWeek(week.weekStart),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Bảng chi tiết theo tuần.
class WeeklyTable extends StatelessWidget {
  const WeeklyTable({super.key, required this.weeks});

  final List<DashboardWeek> weeks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(constraints: BoxConstraints(minWidth: constraints.maxWidth), child: _table()),
      ),
    );
  }

  Widget _table() {
    return DataTable(
        columns: const [
          DataColumn(label: Text('Tuần từ')),
          DataColumn(label: Text('Lượt quét'), numeric: true),
          DataColumn(label: Text('Tỷ lệ hài lòng'), numeric: true),
          DataColumn(label: Text('Chuyển sang Google'), numeric: true),
          DataColumn(label: Text('Đánh giá Google'), numeric: true),
          DataColumn(label: Text('Điểm sao Google'), numeric: true),
        ],
        rows: [
          for (final week in weeks.reversed)
            DataRow(cells: [
              DataCell(Text(formatWeek(week.weekStart))),
              DataCell(Text(formatCount(week.scanCount))),
              DataCell(Text(formatPercent(week.satisfactionRate))),
              DataCell(Text(formatCount(week.googleRedirectCount))),
              DataCell(Text(week.googleReviewCount == null ? '—' : formatCount(week.googleReviewCount!))),
              DataCell(Text(formatRating(week.googleAvgRating))),
            ]),
        ],
    );
  }
}
