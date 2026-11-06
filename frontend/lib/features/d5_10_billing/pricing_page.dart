import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/notice_banner.dart';
import '../d4_01_alert_channels/alert_channels_page.dart' show formatDateTime;
import 'billing_api.dart';
import 'billing_models.dart';

/// D5-10 · Bảng giá và chọn gói (E8.1). Dữ liệu gói lấy từ bảng plans qua API.
class PricingPage extends StatefulWidget {
  const PricingPage({super.key, required this.session});

  final SessionController session;

  @override
  State<PricingPage> createState() => _PricingPageState();
}

class _PricingPageState extends State<PricingPage> {
  late final _api = BillingApi(widget.session.api);
  List<BillingPlan> _plans = const [];
  Subscription? _subscription;
  BillingCycle _cycle = BillingCycle.monthly;
  bool _loading = true;
  String? _error;
  String? _loadedBusinessId;

  bool get _isOwner => widget.session.membership?.role == 'OWNER';

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSessionChanged);
    _onSessionChanged();
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    final businessId = widget.session.business?.id;
    if (businessId != null && businessId != _loadedBusinessId) {
      _loadedBusinessId = businessId;
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plans = await _api.plans();
      final subscription = _isOwner ? await _api.subscription(_loadedBusinessId!) : null;
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _subscription = subscription;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _choose(BillingPlan plan, BillingCycle cycle) {
    context.go('/billing/plans/checkout?planId=${plan.id}&cycle=${cycle.apiCode}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lifetimePlans = _plans.where((plan) => plan.lifetimePrice != null).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(35, 24, 35, 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1115),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bảng giá và chọn gói', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Chọn gói phù hợp với quy mô cơ sở. Giá chưa gồm VAT $vatPercent%.',
              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 20),
            if (_loading)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              NoticeBanner(
                message: _error!,
                type: NoticeType.error,
                action: TextButton(onPressed: _load, child: const Text('Thử lại')),
              )
            else ...[
              if (!_isOwner) ...[
                const NoticeBanner(message: 'Chỉ Chủ cơ sở được mua hoặc gia hạn gói dịch vụ.', type: NoticeType.warning),
                const SizedBox(height: 16),
              ],
              if (_subscription?.isActive ?? false) ...[
                NoticeBanner(message: currentPlanText(_subscription!)),
                const SizedBox(height: 16),
              ],
              SegmentedButton<BillingCycle>(
                segments: const [
                  ButtonSegment(value: BillingCycle.monthly, label: Text('Theo tháng')),
                  ButtonSegment(value: BillingCycle.yearly, label: Text('Theo năm, giảm 20%')),
                ],
                selected: {_cycle},
                onSelectionChanged: (value) => setState(() => _cycle = value.first),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final plan in _plans)
                    SizedBox(
                      width: 340,
                      child: PlanCard(
                        plan: plan,
                        cycle: _cycle,
                        actionLabel: planActionLabel(plan, _cycle, _subscription, _plans),
                        onChoose: _isOwner ? () => _choose(plan, _cycle) : null,
                      ),
                    ),
                ],
              ),
              if (lifetimePlans.isNotEmpty) ...[
                const SizedBox(height: 28),
                Text('Gói ấn phẩm kèm tài khoản trọn đời', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final plan in lifetimePlans)
                      SizedBox(
                        width: 340,
                        child: PlanCard(
                          plan: plan,
                          cycle: BillingCycle.lifetime,
                          titlePrefix: 'Trọn đời ',
                          actionLabel: 'Mua gói trọn đời',
                          onChoose: _isOwner ? () => _choose(plan, BillingCycle.lifetime) : null,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 28),
              Text('So sánh chi tiết các gói', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              PlanComparisonTable(plans: _plans),
            ],
          ],
        ),
      ),
    );
  }
}

String currentPlanText(Subscription subscription) {
  final name = subscription.planName ?? '';
  final end = subscription.endDate;
  if (end == null) return 'Bạn đang dùng gói $name trọn đời.';
  return 'Bạn đang dùng gói $name, hết hạn ngày ${formatDateTime(end).split(' ').first}.';
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.cycle,
    required this.actionLabel,
    required this.onChoose,
    this.titlePrefix = '',
  });

  final BillingPlan plan;
  final BillingCycle cycle;
  final String? actionLabel;
  final VoidCallback? onChoose;
  final String titlePrefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = plan.priceFor(cycle);
    final features = cycle == BillingCycle.lifetime && plan.includedPrintItems != null
        ? [plan.includedPrintItems!, ...plan.features]
        : plan.features;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$titlePrefix${plan.name}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              price == null ? 'Liên hệ' : formatMoney(price),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(cycle.unit, style: theme.textTheme.bodySmall?.copyWith(color: context.colors.textMuted)),
            const SizedBox(height: 12),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, size: 18, color: context.colors.success),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: actionLabel == null || price == null ? null : onChoose,
                child: Text(actionLabel ?? 'Đang sử dụng'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key, required this.plans});

  final List<BillingPlan> plans;

  static String _limit(int? value) => value == null ? 'Không giới hạn' : value.toString();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Tiêu chí')),
          for (final plan in plans) DataColumn(label: Text(plan.name)),
        ],
        rows: [
          DataRow(cells: [
            const DataCell(Text('Giá theo tháng')),
            for (final plan in plans) DataCell(Text(plan.monthlyPrice == null ? '—' : formatMoney(plan.monthlyPrice!))),
          ]),
          DataRow(cells: [
            const DataCell(Text('Giá theo năm')),
            for (final plan in plans) DataCell(Text(plan.yearlyPrice == null ? '—' : formatMoney(plan.yearlyPrice!))),
          ]),
          DataRow(cells: [
            const DataCell(Text('Giá trọn đời')),
            for (final plan in plans) DataCell(Text(plan.lifetimePrice == null ? '—' : formatMoney(plan.lifetimePrice!))),
          ]),
          DataRow(cells: [
            const DataCell(Text('Số chi nhánh')),
            for (final plan in plans) DataCell(Text(_limit(plan.maxBranches))),
          ]),
          DataRow(cells: [
            const DataCell(Text('Số mã QR')),
            for (final plan in plans) DataCell(Text(_limit(plan.maxQrCodes))),
          ]),
        ],
      ),
    );
  }
}
