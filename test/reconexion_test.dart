import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_categorias_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/watch_productos_usecase.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_event.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_state.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_pedidos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedido_usecase.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';
import 'package:mocca_go/utils/reconexion.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_pedidos.dart';

/// Como Supabase al cambiar de red: la primera suscripción falla.
Stream<T> _caida<T>() => Stream<T>.error(Exception('RealtimeSubscribeException(channelError)'));

class _CatalogoQueSeCae extends FakeCatalogoRepository {
  int suscripciones = 0;

  @override
  Stream<List<Producto>> watchProductos() =>
      ++suscripciones == 1 ? _caida() : super.watchProductos();
}

class _PedidosQueSeCaen extends FakePedidoRepository {
  _PedidosQueSeCaen(super.catalogo);

  int suscripciones = 0;

  @override
  Stream<List<Pedido>> watchMisPedidos({required bool activos}) =>
      ++suscripciones <= 2 ? _caida() : super.watchMisPedidos(activos: activos);

  @override
  Stream<Pedido> watchPedido(String pedidoId) =>
      ++suscripciones == 1 ? _caida() : super.watchPedido(pedidoId);
}

void main() {
  const espera = Duration(milliseconds: 20);
  Future<void> esperar() => Future<void>.delayed(const Duration(milliseconds: 80));

  Future<Pedido> crear(FakePedidoRepository pedidos) => pedidos.crear(
    const NuevoPedido(
      lineas: [LineaPedido(productoId: 'americano', cantidad: 1, precioUnitario: 4000)],
      zonaId: 'labs',
      referencia: 'Entrada',
      metodo: MetodoPago.efectivo,
    ),
  );

  test('Menú: avisa sin texto técnico y se reconecta solo', () async {
    final catalogo = _CatalogoQueSeCae();
    final bloc = MenuBloc(
      GetCategoriasUseCase(catalogo),
      WatchProductosUseCase(catalogo),
      espera: espera,
    );
    final avisos = <String>[];
    bloc.stream.where((s) => s.errorMessage != null).listen((s) => avisos.add(s.errorMessage!));

    bloc.add(MenuStarted());
    await esperar();

    expect(avisos, [mensajeSinConexion]);
    expect(catalogo.suscripciones, 2);
    expect(bloc.state.status, MenuStatus.success);
    expect(bloc.state.errorMessage, isNull);
    expect(bloc.state.productos, isNotEmpty);
    await bloc.close();
  });

  test('Mis pedidos: se reconecta solo y vuelve a escuchar cambios', () async {
    final pedidos = _PedidosQueSeCaen(FakeCatalogoRepository())..usuarioActual = 'laura';
    await crear(pedidos);
    final bloc = MisPedidosBloc(WatchMisPedidosUseCase(pedidos), espera: espera);

    bloc.add(MisPedidosStarted());
    await esperar();
    expect(bloc.state.status, MisPedidosStatus.success);
    expect(bloc.state.errorMessage, isNull);
    expect(bloc.state.pedidosActivos!.length, 1);

    // Ya reconectado, un pedido nuevo llega en tiempo real.
    await crear(pedidos);
    await esperar();
    expect(bloc.state.pedidosActivos!.length, 2);
    await bloc.close();
  });

  test('Seguimiento: el aviso de conexión se quita solo al llegar datos', () async {
    final pedidos = _PedidosQueSeCaen(FakeCatalogoRepository())..usuarioActual = 'laura';
    final pedido = await crear(pedidos);
    final calificaciones = FakeCalificacionRepository();
    final bloc = SeguimientoBloc(
      WatchPedidoUseCase(pedidos),
      CancelarPedidoUseCase(pedidos),
      CalificarUseCase(calificaciones),
      GetMiCalificacionUseCase(calificaciones),
      pedido,
      espera: espera,
    );
    final avisos = <String>[];
    bloc.stream.where((s) => s.errorMessage != null).listen((s) => avisos.add(s.errorMessage!));

    bloc.add(SeguimientoStarted());
    await esperar();
    expect(avisos, [mensajeSinConexion]);
    expect(bloc.state.status, SeguimientoStatus.success);
    expect(bloc.state.errorMessage, isNull);

    // Reconectado: el cambio del domiciliario llega solo.
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.tomar(pedido.id);
    await esperar();
    expect(bloc.state.pedido.estado, EstadoPedido.aceptado);
    await bloc.close();
  });

  test('Cerrar el Bloc cancela la reconexión pendiente', () async {
    final catalogo = _CatalogoQueSeCae();
    final bloc = MenuBloc(
      GetCategoriasUseCase(catalogo),
      WatchProductosUseCase(catalogo),
      espera: const Duration(milliseconds: 50),
    );
    bloc.add(MenuStarted());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await bloc.close();
    await esperar();
    expect(catalogo.suscripciones, 1);
  });
}
