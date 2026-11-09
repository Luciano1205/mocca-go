import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_event.dart';
import 'package:mocca_go/features/menu/ui/pages/menu_page.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/pages/mis_pedidos_page.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/widgets/panel_tab_bar.dart';

/// Panel del cliente con sus pestañas: Menú, Mis pedidos y Perfil. Como en
/// el Laboratorio 6, el panel lanza la carga de cada pestaña al abrirla.
class ClientePanelScreen extends StatefulWidget {
  final Usuario usuario;

  const ClientePanelScreen({super.key, required this.usuario});

  @override
  State<ClientePanelScreen> createState() => _ClientePanelScreenState();
}

class _ClientePanelScreenState extends State<ClientePanelScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // El carrito es global: una sesión nueva no hereda el de la anterior.
    context.read<CarritoBloc>().add(CarritoVaciado());
    context.read<MenuBloc>().add(MenuRequested());
  }

  void _cambiarPestana(int index) {
    setState(() => _index = index);
    // Sin tiempo real todavía: cada vez que se abre Mis pedidos, se recarga.
    if (index == 1) context.read<MisPedidosBloc>().add(MisPedidosRequested());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MenuPage(nombre: widget.usuario.nombre.split(' ').first),
      const MisPedidosPage(),
      PerfilPage(usuario: widget.usuario),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: PanelTabBar(
        currentIndex: _index,
        onTap: _cambiarPestana,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.coffee_outlined), label: 'Menú'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Mis pedidos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
