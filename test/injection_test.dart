import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_bloc.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_bloc.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_bloc.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_bloc.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/crear_pedido_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_bloc.dart';
import 'package:mocca_go/features/register/ui/bloc/register_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_bloc.dart';
import 'package:mocca_go/injection_container.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_dependencias.dart';
import 'fakes/fake_pedidos.dart';
import 'fakes/fake_repositories.dart';

void main() {
  late FakePedidoRepository pedidos;

  setUp(() {
    final catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
    registrarFakes(
      auth: FakeAuthRepository(),
      usuarios: FakeUsuarioRepository(),
      catalogo: catalogo,
      pedidos: pedidos,
      calificaciones: FakeCalificacionRepository(),
      reclamos: FakeReclamoRepository(),
    );
  });

  test('GetIt arma todos los Blocs de la app', () async {
    final pedido = await sl<CrearPedidoUseCase>()(
      const NuevoPedido(
        lineas: [LineaPedido(productoId: 'americano', cantidad: 1, precioUnitario: 4000)],
        zonaId: 'labs',
        referencia: 'Entrada',
        metodo: MetodoPago.efectivo,
      ),
    );
    const usuario = Usuario(id: 'u', nombre: 'Laura', correo: 'l@u.co', rol: Rol.cliente);

    expect(sl<SplashBloc>(), isA<SplashBloc>());
    expect(sl<LoginBloc>(), isA<LoginBloc>());
    expect(sl<RegisterBloc>(), isA<RegisterBloc>());
    expect(sl<RecoverBloc>(), isA<RecoverBloc>());
    expect(sl<NewPasswordBloc>(), isA<NewPasswordBloc>());
    expect(sl<PanelBloc>(), isA<PanelBloc>());
    expect(sl<EditarPerfilBloc>(param1: usuario), isA<EditarPerfilBloc>());
    expect(sl<CarritoBloc>(), isA<CarritoBloc>());
    expect(sl<MenuBloc>(), isA<MenuBloc>());
    expect(sl<MisPedidosBloc>(), isA<MisPedidosBloc>());
    expect(sl<DatosEntregaBloc>(), isA<DatosEntregaBloc>());
    expect(sl<SeguimientoBloc>(param1: pedido), isA<SeguimientoBloc>());
    expect(sl<PendientesBloc>(), isA<PendientesBloc>());
    expect(sl<MisEntregasBloc>(), isA<MisEntregasBloc>());
    expect(sl<ProductosBloc>(), isA<ProductosBloc>());
    expect(sl<DetallePedidoBloc>(param1: pedido), isA<DetallePedidoBloc>());
    expect(sl<GestionarPedidoBloc>(param1: pedido), isA<GestionarPedidoBloc>());
  });

  test('Los Blocs son nuevos cada vez y los casos de uso se reutilizan', () {
    expect(identical(sl<LoginBloc>(), sl<LoginBloc>()), isFalse);
    expect(identical(sl<CrearPedidoUseCase>(), sl<CrearPedidoUseCase>()), isTrue);
  });
}
