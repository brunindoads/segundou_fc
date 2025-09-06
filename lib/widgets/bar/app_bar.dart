import 'package:flutter/material.dart';

/// Defina os itens disponíveis na navbar
enum NavItem { dashboard, ranking, historico, configuracoes }

/// Sidebar minimalista com degradê verde→laranja
class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.selected,
    required this.onSelected,
    this.logoAsset = 'assets/app_icon.png',
    this.width = 240,
    this.collapsedWidth = 72,
    this.collapsible = false,
  });

  /// Item selecionado
  final NavItem selected;

  /// Callback quando um item é selecionado
  final ValueChanged<NavItem> onSelected;

  /// Caminho do asset da imagem do ícone no topo
  final String logoAsset;

  /// Largura expandida da barra
  final double width;

  /// Largura quando colapsada (se [collapsible] = true)
  final double collapsedWidth;

  /// Habilita modo colapsável (útil em telas menores)
  final bool collapsible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCollapsed = collapsible && MediaQuery.of(context).size.width < 900;

    final items = <_SideItem>[
      const _SideItem(
        item: NavItem.dashboard,
        label: 'Dashboard',
        icon: Icons.space_dashboard_rounded,
      ),
      const _SideItem(
        item: NavItem.ranking,
        label: 'Ranking',
        icon: Icons.emoji_events_rounded,
      ),
      const _SideItem(
        item: NavItem.historico,
        label: 'Histórico',
        icon: Icons.history_rounded,
      ),
      const _SideItem(
        item: NavItem.configuracoes,
        label: 'Configurações',
        icon: Icons.settings_rounded,
      ),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? collapsedWidth : width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 1, 102, 43), // verde
            Color(0xFFFF9800), // laranja
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Topo: ícone do app
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: isCollapsed ? 12 : 20,
                horizontal: isCollapsed ? 8 : 16,
              ),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    logoAsset,
                    width: isCollapsed ? 36 : 64,
                    height: isCollapsed ? 36 : 64,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Lista de itens
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final i = items[index];
                  final bool isSelected = i.item == selected;

                  return _SidebarTile(
                    icon: i.icon,
                    label: i.label,
                    isSelected: isSelected,
                    compact: isCollapsed,
                    onTap: () => onSelected(i.item),
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SideItem {
  const _SideItem({
    required this.item,
    required this.label,
    required this.icon,
  });
  final NavItem item;
  final String label;
  final IconData icon;
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.compact,
    required this.textStyle,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool compact;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    const baseColor = Colors.white;
    final selectedBg = Colors.white.withOpacity(0.18);
    final hoverBg = Colors.white.withOpacity(0.10);

    return _MinimalInk(
      borderRadius: BorderRadius.circular(14),
      hoverColor: hoverBg,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.25))
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: baseColor, size: compact ? 22 : 24),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Componente auxiliar para manter o efeito de hover minimalista sem splash exagerado
class _MinimalInk extends StatelessWidget {
  const _MinimalInk({
    required this.child,
    this.borderRadius,
    this.hoverColor,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: borderRadius,
        ),
        child: InkResponse(
          highlightShape: BoxShape.rectangle,
          highlightColor: hoverColor,
          containedInkWell: true,
          borderRadius: borderRadius ?? BorderRadius.zero,
          splashColor: Colors.white24.withOpacity(0.08),
          radius: 20,
          onTap: () {},
          child: child,
        ),
      ),
    );
  }
}
