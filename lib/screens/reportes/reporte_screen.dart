import 'package:flutter/material.dart';
// import 'package:frontend_soderia/core/colors.dart';

import 'reporte_resumen_diario_screen.dart';
import 'reporte_repartos_screen.dart';
import 'reporte_caja_empresa_screen.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Resumen'),
            Tab(text: 'Repartos'),
            Tab(text: 'Caja'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReporteResumenDiarioScreen(),
          ReporteRepartosScreen(),
          ReporteCajaEmpresaScreen(),
        ],
      ),
    );
  }
}

