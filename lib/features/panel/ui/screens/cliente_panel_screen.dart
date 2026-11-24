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
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/mis_pedidos/ui/pages/mis_pedidos_page.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/widgets/panel_tab_bar.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/notificaciones/notificaciones_locales.dart';

/// Panel del cliente con sus pestañas: Menú, Mis pedidos y Perfil. Al entrar
/// abre las suscripciones en tiempo real del menú y de Mis pedidos, que
/// siguen vivas aunque se cambie de pestaña.
class ClientePanelScreen extends StatefulWidget {
  final Usuario usuario;

  const ClientePanelScreen({super.key, required this.usuario});

  @override
  State<ClientePanelScreen> createState() => _ClientePanelScreenState();
}

class _ClientePanelScreenState extends State<ClientePanelScreen> {
  int _index = 0;

  /// El perfil puede cambiar en Editar perfil.
  late Usuario _usuario = widget.usuario;

  @override
  void initState() {
    super.initState();
    // El carrito es global: una sesión nueva no hereda el de la anterior.
    context.read<CarritoBloc>().add(CarritoVaciado());
    context.read<MenuBloc>().add(MenuStarted());
    context.read<MisPedidosBloc>().add(MisPedidosStarted());
  }

  void _cambiarPestana(int index) => setState(() => _index = index);

  /// 11b · El domiciliario aceptó, salió o entregó el pedido.
  void _notificarCambio(Pedido pedido) {
    final nombre = (pedido.domiciliarioNombre ?? 'El domiciliario').split(' ').first;
    switch (pedido.estado) {
      case EstadoPedido.aceptado:
        NotificacionesLocales.mostrar(
          titulo: 'Tu pedido fue aceptado',
          cuerpo: '$nombre está preparando tu pedido #${pedido.numero}.',
        );
      case EstadoPedido.enCamino:
        NotificacionesLocales.mostrar(
          titulo: 'Tu pedido va en camino',
          cuerpo: '$nombre lleva tu pedido #${pedido.numero} a ${pedido.zona}.',
        );
      case EstadoPedido.entregado:
        NotificacionesLocales.mostrar(
          titulo: 'Tu pedido llegó',
          cuerpo: 'Disfrútalo. Califica a $nombre en el seguimiento.',
        );
      case EstadoPedido.pendiente:
      case EstadoPedido.cancelado:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MenuPage(nombre: _usuario.nombre.split(' ').first),
      const MisPedidosPage(),
      PerfilPage(usuario: _usuario, onUsuarioActualizado: (u) => setState(() => _usuario = u)),
    ];
    // El aviso se escucha aquí y no en la pestaña Mis pedidos, para que
    // llegue aunque el cliente esté en el menú o en su perfil.
    return BlocListener<MisPedidosBloc, MisPedidosState>(
      listenWhen: (antes, ahora) => ahora.cambio != null && ahora.cambio != antes.cambio,
      listener: (_, state) => _notificarCambio(state.cambio!),
      child: Scaffold(
        body: SafeArea(child: pages[_index]),
        bottomNavigationBar: PanelTabBar(
          currentIndex: _index,
          onTap: _cambiarPestana,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.coffee_outlined), label: 'Menú'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Mis pedidos'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}
