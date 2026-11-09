import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_client.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/admin_page.dart';
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
    return AdminPage(
      title: 'Gói dịch vụ Review Funnel',
      subtitle: 'Giá chưa gồm VAT $vatPercent%. Trả theo năm giảm 20% so với trả theo tháng.',
      actions: SizedBox(
        width: 260,
        child: SegmentedButton<BillingCycle>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: BillingCycle.monthly, label: Text('Theo tháng')),
            ButtonSegment(value: BillingCycle.yearly, label: Text('Theo năm')),
          ],
          selected: {_cycle},
          onSelectionChanged: (value) => setState(() => _cycle = value.first),
        ),
      ),
      children: [
        if (_loading)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          NoticeBanner(
            message: _error!,
            type: NoticeType.error,
            action: TextButton(onPressed: _load, child: const Text('Tải lại bảng giá')),
          )
        else ...[
          if (!_isOwner) ...[
            const NoticeBanner(message: 'Chỉ Chủ cơ sở được mua hoặc gia hạn gói dịch vụ.', type: NoticeType.warning),
            const SizedBox(height: AppSpace.lg),
          ],
          if (_subscription?.isActive ?? false) ...[
            NoticeBanner(
              message: currentPlanText(_subscription!),
              action: TextButton.icon(
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Quản lý thuê bao & hóa đơn'),
                onPressed: () => context.go('/billing/subscription'),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
          ],
          ResponsiveGrid(
            children: [
              for (final plan in _plans)
                PlanCard(
                  plan: plan,
                  cycle: _cycle,
                  actionLabel: planActionLabel(plan, _cycle, _subscription, _plans),
                  primary: _subscription?.isActive == true && _subscription?.planId == plan.id,
                  onChoose: _isOwner ? () => _choose(plan, _cycle) : null,
                ),
            ],
          ),
          if (lifetimePlans.isNotEmpty) ...[
            const SizedBox(height: AppSpace.xxl),
            Text('Gói trọn đời kèm ấn phẩm', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpace.xs),
            Text('Trả một lần, dùng tài khoản không thời hạn và nhận bộ ấn phẩm QR in sẵn.', style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpace.lg),
            ResponsiveGrid(
              maxColumns: 2,
              children: [
                for (final plan in lifetimePlans)
                  PlanCard(
                    plan: plan,
                    cycle: BillingCycle.lifetime,
                    titlePrefix: 'Trọn đời ',
                    actionLabel: 'Mua gói trọn đời',
                    onChoose: _isOwner ? () => _choose(plan, BillingCycle.lifetime) : null,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.xxl),
          SectionCard(title: 'So sánh giá và giới hạn các gói', child: PlanComparisonTable(plans: _plans)),
        ],
      ],
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
    this.primary = false,
  });

  final BillingPlan plan;
  final BillingCycle cycle;
  final String? actionLabel;
  final VoidCallback? onChoose;
  final String titlePrefix;

  /// Nút tô đặc chỉ dành cho gói đang dùng, các gói khác dùng nút viền.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final price = plan.priceFor(cycle);
    final features = cycle == BillingCycle.lifetime && plan.includedPrintItems != null
        ? [plan.includedPrintItems!, ...plan.features]
        : plan.features;
    final onPressed = actionLabel == null || price == null ? null : onChoose;
    final label = Text(actionLabel ?? 'Đang sử dụng');
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('$titlePrefix${plan.name}', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpace.md),
            Text(price == null ? 'Liên hệ' : formatMoney(price), style: theme.textTheme.headlineSmall),
            Text(cycle.unit, style: theme.textTheme.bodySmall),
            const SizedBox(height: AppSpace.lg),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(Icons.check, size: 16, color: context.colors.success),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            const Spacer(),
            const SizedBox(height: AppSpace.md),
            if (primary)
              FilledButton(onPressed: onPressed, child: label)
            else
              OutlinedButton(onPressed: onPressed, child: label),
          ],
        ),
      ),
    );
    return onPressed == null ? card : HoverCard(child: card);
  }
}

class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({super.key, required this.plans});

  final List<BillingPlan> plans;

  static String _limit(int? value) => value == null ? 'Không giới hạn' : value.toString();

  static String _price(int? value) => value == null ? '—' : formatMoney(value);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: constraints.maxWidth),
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Tiêu chí')),
              for (final plan in plans) DataColumn(label: Text(plan.name)),
            ],
            rows: [
              _row('Giá theo tháng', (plan) => _price(plan.monthlyPrice)),
              _row('Giá theo năm', (plan) => _price(plan.yearlyPrice)),
              _row('Giá trọn đời', (plan) => _price(plan.lifetimePrice)),
              _row('Số chi nhánh', (plan) => _limit(plan.maxBranches)),
              _row('Số mã QR', (plan) => _limit(plan.maxQrCodes)),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _row(String label, String Function(BillingPlan plan) value) => DataRow(cells: [
        DataCell(Text(label)),
        for (final plan in plans) DataCell(Text(value(plan))),
      ]);
}
