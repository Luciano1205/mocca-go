import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_event.dart';
import 'package:mocca_go/features/mis_entregas/ui/pages/mis_entregas_page.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/widgets/panel_tab_bar.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_state.dart';
import 'package:mocca_go/features/pendientes/ui/pages/pendientes_page.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_bloc.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_event.dart';
import 'package:mocca_go/features/productos/ui/pages/productos_page.dart';
import 'package:mocca_go/notificaciones/notificaciones_locales.dart';
import 'package:mocca_go/utils/formato.dart';

/// Panel del domiciliario con sus pestañas: Pedidos, Mis entregas,
/// Productos y Perfil. Al entrar abre las suscripciones en tiempo real del
/// feed y de Mis entregas, que siguen vivas aunque se cambie de pestaña.
class ProveedorPanelScreen extends StatefulWidget {
  final Usuario usuario;

  const ProveedorPanelScreen({super.key, required this.usuario});

  @override
  State<ProveedorPanelScreen> createState() => _ProveedorPanelScreenState();
}

class _ProveedorPanelScreenState extends State<ProveedorPanelScreen> {
  int _index = 0;

  /// El perfil puede cambiar en Editar perfil.
  late Usuario _usuario = widget.usuario;

  @override
  void initState() {
    super.initState();
    context.read<PendientesBloc>().add(PendientesStarted());
    context.read<MisEntregasBloc>().add(MisEntregasStarted());
    context.read<ProductosBloc>().add(ProductosStarted());
  }

  void _cambiarPestana(int index) => setState(() => _index = index);

  /// 14b · "Nuevo pedido · $4.000. Sofía pidió 1 Americano a Laboratorios."
  void _notificarNuevo(PendientesState state) {
    final pedido = state.nuevo!;
    final nombre = pedido.clienteNombre.split(' ').first;
    NotificacionesLocales.mostrar(
      titulo: 'Nuevo pedido · ${formatoPesos(pedido.total)}',
      cuerpo: '$nombre pidió ${pedido.resumenItems} a ${pedido.zona}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const PendientesPage(),
      const MisEntregasPage(),
      const ProductosPage(),
      PerfilPage(
        usuario: _usuario,
        onUsuarioActualizado: (u) => setState(() => _usuario = u),
      ),
    ];
    // El aviso se escucha aquí y no en la pestaña Pedidos, para que llegue
    // aunque el domiciliario esté en otra pestaña.
    return BlocListener<PendientesBloc, PendientesState>(
      listenWhen: (antes, ahora) => ahora.nuevo != null && ahora.nuevo != antes.nuevo,
      listener: (_, state) => _notificarNuevo(state),
      child: Scaffold(
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
      ),
    );
  }
}
