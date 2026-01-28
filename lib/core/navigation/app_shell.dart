import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/app_shell_actions.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';
import 'package:frontend_soderia/core/navigation/shell_state.dart';
import 'package:frontend_soderia/services/auth_service.dart';
import 'package:frontend_soderia/widgets/app_header.dart';
import 'package:frontend_soderia/core/session/session_state.dart';

/// AppShell adaptativo:
/// - Móvil  (<600): AppBar + Drawer modal
/// - Tablet (600–1024): AppBar + NavigationRail
/// - Desktop(>=1024): Drawer persistente
///
/// Mantiene estado por sección con IndexedStack.
/// Exposición de FAB y título dinámico por sección.

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.pages, // Opción A: lista fija de páginas
    this.pagesBuilder, // Opción B: fábrica que recibe el _select
    this.initialIndex = 0,
    this.onRouteChange,
    this.fabBuilder,
    this.titleBuilder,
  }) : assert(
         pages != null || pagesBuilder != null,
         'Debes proveer pages o pagesBuilder',
       );

  /// Lista fija de páginas. El orden debe coincidir con kDestinations.
  final List<Widget>? pages;

  /// Fábrica de páginas que recibe el callback select (cambiar de pestaña).
  final List<Widget> Function(void Function(int) select)? pagesBuilder;

  /// Índice inicial.
  final int initialIndex;

  /// Callback opcional al cambiar de sección (útil para analytics/deep-link).
  final void Function(int index, AppDestination dest)? onRouteChange;

  /// FAB opcional por sección.
  final Widget? Function(BuildContext context, int index)? fabBuilder;

  /// Título opcional por sección. Si devuelve '', no se muestra título.
  final String Function(int index, AppDestination dest)? titleBuilder;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;
  late final VoidCallback _shellListener; // 👈 Nuevo listener

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, kDestinations.length - 1);

    // Sincroniza el estado global al iniciar
    shellState.value = _index;

    // Listener que escucha cambios globales y actualiza la UI
    _shellListener = () {
      if (shellState.value != _index && mounted) {
        setState(() => _index = shellState.value);
        widget.onRouteChange?.call(_index, kDestinations[_index]);
      }
    };

    shellState.addListener(_shellListener);
  }

  @override
  void dispose() {
    shellState.removeListener(_shellListener); // evita fugas de memoria
    super.dispose();
  }

  void _select(int newIndex) {
    if (newIndex == _index) return;

    // Actualiza UI local
    setState(() => _index = newIndex);

    // Propaga el cambio globalmente
    shellState.selectTab(newIndex);

    widget.onRouteChange?.call(newIndex, kDestinations[newIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width;
    final isMobile = w < 600;
    final isRail = w >= 600 && w < 1024;

    // Construye las páginas (inyectando _select si se usa pagesBuilder)
    final pages = widget.pagesBuilder?.call(_select) ?? widget.pages!;
    assert(
      pages.length == kDestinations.length,
      'pages y kDestinations deben tener el mismo largo y orden',
    );

    // Título dinámico (si titleBuilder devuelve '', no se muestra)
    final titleText =
        widget.titleBuilder?.call(_index, kDestinations[_index]) ??
        kDestinations[_index].label;

    final fab = widget.fabBuilder?.call(context, _index);

    // Contenido principal preservando estado por pestaña
    final body = IndexedStack(
      index: _index,
      children: [
        for (var i = 0; i < pages.length; i++)
          HeroMode(
            enabled:
                i == _index, // 👈 solo la pestaña visible puede tener heroes
            child: pages[i],
          ),
      ],
    );

    // ------- MÓVIL: AppBar + Drawer modal -------
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: AppHeader(sectionTitle: titleText),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              tooltip: 'Abrir menú',
            ),
          ),
        ),
        drawer: _ModalDrawer(selectedIndex: _index, onSelect: _select),
        body: body,
        // donde hoy ponés floatingActionButton: fab,
        floatingActionButton:
            fab ??
            (_index == 0
                ? FloatingActionButton.extended(
                    heroTag: null,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar'),
                    onPressed: () => AppShellActions.showAddSheet(context),
                  )
                : null),
      );
    }

    // ------- TABLET: NavigationRail (colapsado) -------
    if (isRail) {
      return Scaffold(
        appBar: AppBar(
          title: AppHeader(sectionTitle: titleText),
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
        ),
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: cs.surface,
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.selected,
              destinations: [
                for (final d in kDestinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
        floatingActionButton: fab,
      );
    }

    // ------- DESKTOP: Drawer persistente -------
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 260,
            child: Drawer(
              elevation: 0,
              child: _PersistentDrawer(
                selectedIndex: _index,
                onSelect: _select,
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: AppHeader(sectionTitle: titleText),
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                elevation: 0,
              ),
              body: body,
              floatingActionButton: fab,
            ),
          ),
        ],
      ),
    );
  }
}

// ====== Drawers ======

class _ModalDrawer extends StatelessWidget {
  const _ModalDrawer({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              'Dashboard',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          for (var i = 0; i < kDestinations.length; i++)
            ListTile(
              leading: Icon(kDestinations[i].icon, color: AppColors.azul),
              title: Text(
                kDestinations[i].label,
                style: const TextStyle(color: AppColors.azul),
              ),
              selected: i == selectedIndex,
              onTap: () {
                Navigator.pop(context);
                onSelect(i);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.azul),
            title: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.azul),
            ),
            onTap: () async {
              final nav = Navigator.of(context, rootNavigator: true);
              Navigator.pop(context); // cerrar drawer
              await AuthService().logout();
              sessionState.clear(); // 👈 ACÁ
              nav.pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

class _PersistentDrawer extends StatelessWidget {
  const _PersistentDrawer({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        for (var i = 0; i < kDestinations.length; i++)
          ListTile(
            leading: Icon(kDestinations[i].icon, color: AppColors.azul),
            title: Text(
              kDestinations[i].label,
              style: const TextStyle(color: AppColors.azul),
            ),
            selected: i == selectedIndex,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onTap: () => onSelect(i),
            // ignore: deprecated_member_use
            hoverColor: AppColors.celeste.withOpacity(0.08),
            // ignore: deprecated_member_use
            selectedTileColor: AppColors.celeste.withOpacity(0.12),
          ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout, color: AppColors.azul),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(color: AppColors.azul),
          ),
          onTap: () async {
            final nav = Navigator.of(context, rootNavigator: true);
            Navigator.pop(context); // cerrar drawer
            await AuthService().logout();
            sessionState.clear(); // 👈 ACÁ
            nav.pushNamedAndRemoveUntil('/login', (route) => false);
          },
        ),
      ],
    );
  }
}
