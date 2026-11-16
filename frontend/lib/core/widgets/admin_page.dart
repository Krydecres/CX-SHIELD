import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thang khoảng cách dùng chung cho các màn quản trị.
abstract final class AppSpace {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Chuyển động giao diện: ngắn, không nảy, tắt dịch chuyển khi người dùng bật giảm chuyển động.
abstract final class AppMotion {
  static const hoverIn = Duration(milliseconds: 140);
  static const hoverOut = Duration(milliseconds: 200);
  static const curve = Cubic(.2, .8, .2, 1);
  static const hoverLift = 2.0;
}

/// Bề rộng từ đó trở xuống dùng bố cục điện thoại.
const double compactWidth = 640;

/// Khung trang quản trị: tiêu đề, mô tả, thao tác bên phải và nội dung; lề trái phải bằng nhau.
class AdminPage extends StatelessWidget {
  const AdminPage({super.key, required this.title, this.subtitle, this.actions, required this.children});

  final String title;
  final String? subtitle;
  final Widget? actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < compactWidth;
        final gutter = compact ? AppSpace.lg : AppSpace.xxl;
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(subtitle!, style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textSecondary)),
            ],
          ],
        );
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: gutter, vertical: compact ? AppSpace.lg : AppSpace.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (actions == null || compact) heading else Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child: heading), const SizedBox(width: AppSpace.xl), actions!],
                  ),
                  if (actions != null && compact) ...[const SizedBox(height: AppSpace.lg), actions!],
                  const SizedBox(height: AppSpace.xl),
                  ...children,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lưới cột bằng nhau, các ô trong một hàng cao bằng nhau. Số cột giảm theo bề rộng thật của vùng chứa.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children, this.minItemWidth = 280, this.maxColumns = 3});

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth < compactWidth ? AppSpace.md : AppSpace.xl;
        final fit = ((constraints.maxWidth + gap) / (minItemWidth + gap)).floor();
        final columns = fit.clamp(1, maxColumns);
        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final end = (start + columns).clamp(0, children.length);
          final items = children.sublist(start, end);
          if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
          rows.add(IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) SizedBox(width: gap),
                  Expanded(child: i < items.length ? items[i] : const SizedBox.shrink()),
                ],
              ],
            ),
          ));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}

/// Khối nội dung có tiêu đề, dùng chung một kiểu thẻ trên mọi màn.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, this.subtitle, required this.child});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpace.xs),
              Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpace.lg),
            child,
          ],
        ),
      ),
    );
  }
}

/// Thẻ nhấc 2px khi rê chuột, chỉ dùng cho thẻ có hành động.
class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child});

  final Widget child;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lifted = _hovered && !MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: _hovered ? AppMotion.hoverIn : AppMotion.hoverOut,
        curve: AppMotion.curve,
        transform: Matrix4.translationValues(0, lifted ? -AppMotion.hoverLift : 0, 0),
        child: widget.child,
      ),
    );
  }
}
