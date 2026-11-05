import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_event.dart';
import 'package:mocca_go/features/mis_entregas/ui/pages/mis_entregas_page.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/pages/proximamente_page.dart';
import 'package:mocca_go/features/panel/ui/widgets/panel_tab_bar.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/pages/pendientes_page.dart';

/// Panel del domiciliario con sus pestañas: Pedidos, Mis entregas,
/// Productos (sprint 3) y Perfil. Como en el Laboratorio 6, el panel lanza
/// la carga de cada pestaña al abrirla.
class ProveedorPanelScreen extends StatefulWidget {
  final Usuario usuario;

  const ProveedorPanelScreen({super.key, required this.usuario});

  @override
  State<ProveedorPanelScreen> createState() => _ProveedorPanelScreenState();
}

class _ProveedorPanelScreenState extends State<ProveedorPanelScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    context.read<PendientesBloc>().add(PendientesRequested());
  }

  void _cambiarPestana(int index) {
    setState(() => _index = index);
    // Sin tiempo real todavía: cada vez que se abre una lista, se recarga.
    if (index == 0) context.read<PendientesBloc>().add(PendientesRequested());
    if (index == 1) context.read<MisEntregasBloc>().add(MisEntregasRequested());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PendientesPage(),
      const MisEntregasPage(),
      const ProximamentePage(titulo: 'Productos', icono: Icons.coffee_outlined),
      PerfilPage(usuario: widget.usuario),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: PanelTabBar(
        currentIndex: _index,
        onTap: _cambiarPestana,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inbox_outlined), label: 'Pedidos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Mis entregas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.coffee_outlined), label: 'Productos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
