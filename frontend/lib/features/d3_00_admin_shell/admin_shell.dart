import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/account_models.dart';
import '../../core/session/session_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/theme_mode_button.dart';
import 'admin_menu.dart';

/// D3-00 · Khung admin dùng chung: menu bên, header, chọn chi nhánh.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.session, required this.location, required this.child});

  final SessionController session;
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = menuItemFor(location);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            final sidebar = _Sidebar(session: session, current: current);
            return Scaffold(
              drawer: wide ? null : Drawer(width: 245, child: sidebar),
              body: Row(
                children: [
                  if (wide) sidebar,
                  Expanded(
                    child: Column(
                      children: [
                        _Header(session: session, title: current?.label ?? 'Tổng quan', showMenuButton: !wide),
                        Expanded(child: Align(alignment: Alignment.topLeft, child: child)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.session, required this.current});

  final SessionController session;
  final AdminMenuItem? current;

  @override
  Widget build(BuildContext context) {
    final business = session.business;
    final role = session.membership?.role ?? '';
    return Container(
      width: 245,
      color: context.colors.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
              child: Row(
                children: [
                  _BrandLogo(business: business),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      business?.brandName ?? 'Review Funnel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: context.colors.onSidebar, fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: context.colors.sidebarHover, height: 1, indent: 20, endIndent: 20),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final item in adminMenu) _MenuTile(item: item, selected: item == current),
                ],
              ),
            ),
            Divider(color: context.colors.sidebarHover, height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.me?.displayName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: context.colors.onSidebar, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          roleLabel(role, branchCount: session.branches.length),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: context.colors.onSidebarMuted, fontSize: 13),
                        ),
                      ),
                      Text(' · ', style: TextStyle(color: context.colors.onSidebarMuted)),
                      InkWell(
                        onTap: session.signOut,
                        child: Text(
                          'Đăng xuất',
                          style: TextStyle(color: context.colors.onSidebar, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.item, required this.selected});

  final AdminMenuItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: selected ? context.colors.sidebarHover : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            context.go(item.path);
          },
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: selected ? Border(left: BorderSide(color: context.colors.accent, width: 3)) : null,
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 19, color: selected ? context.colors.accent : context.colors.onSidebarMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: selected ? context.colors.onSidebar : context.colors.onSidebarMuted,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.business});

  final Business? business;

  @override
  Widget build(BuildContext context) {
    final logoUrl = business?.logoUrl;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: context.colors.onSidebar, borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: logoUrl != null
          ? Image.network(logoUrl, fit: BoxFit.contain, errorBuilder: (_, _, _) => _initial(context))
          : _initial(context),
    );
  }

  Widget _initial(BuildContext context) {
    final name = business?.brandName ?? 'R';
    return Text(
      name.isEmpty ? 'R' : name.characters.first.toUpperCase(),
      style: TextStyle(color: context.colors.sidebar, fontWeight: FontWeight.w800, fontSize: 16),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session, required this.title, required this.showMenuButton});

  final SessionController session;
  final String title;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(bottom: BorderSide(color: context.colors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Màn hẹp: chọn chi nhánh xuống dòng riêng để tiêu đề không bị ép.
          final narrow = constraints.maxWidth < 560;
          final hasBranches = session.branches.isNotEmpty;
          final topRow = Row(
            children: [
              if (showMenuButton)
                IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge),
                    if (!narrow) ...[
                      const SizedBox(height: 4),
                      Text('Trang chủ / $title', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (hasBranches && !narrow) _BranchSelector(session: session),
              const SizedBox(width: 8),
              const ThemeModeButton(),
            ],
          );
          if (!narrow || !hasBranches) return topRow;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [topRow, const SizedBox(height: 8), _BranchSelector(session: session)],
          );
        },
      ),
    );
  }
}

class _BranchSelector extends StatelessWidget {
  const _BranchSelector({required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    final selected = session.selectedBranch;
    return PopupMenuButton<Branch>(
      tooltip: 'Chọn chi nhánh',
      onSelected: session.selectBranch,
      itemBuilder: (context) => [
        for (final branch in session.branches)
          PopupMenuItem(
            value: branch,
            child: Row(
              children: [
                Icon(
                  branch.id == selected?.id ? Icons.radio_button_checked : Icons.radio_button_off,
                  size: 18,
                  color: branch.id == selected?.id ? context.colors.accent : context.colors.textMuted,
                ),
                const SizedBox(width: 10),
                Text('${branch.name} · ${branch.code}'),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: context.colors.secondarySoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.secondaryBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, size: 18, color: context.colors.secondary),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                'Chi nhánh: ${selected?.name ?? '—'}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.colors.secondary, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: context.colors.secondary),
          ],
        ),
      ),
    );
  }
}
