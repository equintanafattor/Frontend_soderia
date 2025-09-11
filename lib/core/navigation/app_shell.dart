import 'package:flutter/material.dart';
import 'package:frontend_soderia/core/colors.dart';
import 'package:frontend_soderia/core/navigation/destinations.dart';


/// AppShell adaptativo:
/// - Móvil  (<600): AppBar + Drawer modal (icono hamburguesa)
/// - Tablet (600-1024): AppBar + NavigationRail colapsado (siempre visible)
/// - Desktop(>=1024): Drawer persistente (siempre visible)
///
/// Mantiene estado por sección con IndexedStack.
/// Exposición de FAB adaptativo: aparece si el destino actual lo requiere.

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.pages, // Widgets por índice (mismo orden que kDestinations)
    this.initialIndex = 0, 
    this.onRouteChange, // opcional: para analytics o deep-link
    this.fabBuilder, // opcional: FAB distinto por sección
    this.titleBuilder, // opcional: Título dinámico en AppBar
    });

    final List<Widget> pages;
    final int initialIndex; 
    final void Function(int index, AppDestination dest)? onRouteChange; 
    final Widget? Function(BuildContext context, int index)? fabBuilder; 
    final String Function(int index, AppDestination dest)? titleBuilder; 

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index; 

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, kDestinations.length - 1);
  }

  void _select(int newIndex) {
    if (newIndex == _index) return; 
    setState(() => _index = newIndex);
    widget.onRouteChange?.call(newIndex, kDestinations[newIndex]);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = MediaQuery.of(context).size.width; 
    final isMobile = w < 600; 
    final isRail = w >= 600 && w < 1024; 
    final isDesk = w >= 1024; 

    final titleText = widget.titleBuilder?.call(_index, kDestinations[_index]) ??
      kDestinations[_index].label;
    
    final fab = widget.fabBuilder?.call(context, _index);

    // Contenido principal (mantiene estado por tab)
    final body = IndexedStack(
      index: _index,
      children: widget.pages,
    );

    // ------- MÓVIL: AppBar + Drawer modal -------
    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
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
        drawer: _ModalDrawer(
          selectedIndex: _index,
          onSelect: _select,
        ),
        body: body,
        floatingActionButton: fab,
      );
    }

    // ------- TABLET: NavigationRail (colapsado) -------
    if (isRail) {
      return Scaffold(
        appBar: AppBar(
          title: Text(titleText),
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
              leading: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.menu_open),
                  tooltip: 'Abrir menú',
                  onPressed: () {
                    // Opcional: podrías abrir un Drawer temporal con textos completos
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aquí podrías abrir un Drawer temporal con títulos')),
                    );
                  },
                ),
              ),
              destinations: [
                for (final d in kDestinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    label: Text(d.label),
                  )
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
                title: Text(titleText),
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
  const _ModalDrawer({
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect; 

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          ),
          for (var i = 0; i < kDestinations.length; i++)
            ListTile(
              leading: Icon(kDestinations[i].icon, color: AppColors.azul),
              title: Text(kDestinations[i].label, style: const TextStyle(color: AppColors.azul)),
              selected: i == selectedIndex,
              onTap: () {
                Navigator.pop(context);
                onSelect(i);
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
    required this.onSelect
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
          child: Text('Dashboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        for (var i = 0; i < kDestinations.length; i++)
          ListTile(
            leading: Icon(kDestinations[i].icon, color: AppColors.azul),
            title: Text(kDestinations[i].label, style: const TextStyle(color: AppColors.azul)),
            selected: i == selectedIndex,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onTap: () => onSelect(i),
            // ignore: deprecated_member_use
            hoverColor: AppColors.celeste.withOpacity(0.08),
            // ignore: deprecated_member_use
            selectedTileColor: AppColors.celeste.withOpacity(0.12),
          ),
      ],
    );
  }
}