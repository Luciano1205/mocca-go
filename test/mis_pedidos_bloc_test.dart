import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_pedidos_usecase.dart';

import 'fakes/fake_pedidos.dart';

/// Tarea 3 · Notificación de cambio de estado (11b). La notificación la
/// muestra el panel; aquí se prueba que el Bloc avisa del cambio correcto.
void main() {
  late FakePedidoRepository pedidos;
  late MisPedidosBloc bloc;
  late List<MisPedidosState> estados;

  setUp(() async {
    pedidos = FakePedidoRepository(FakeCatalogoRepository());
    pedidos.usuarioActual = 'laura';
    bloc = MisPedidosBloc(WatchMisPedidosUseCase(pedidos));
    estados = [];
    bloc.stream.listen(estados.add);
  });

  tearDown(() => bloc.close());

  Future<void> esperar() => Future<void>.delayed(const Duration(milliseconds: 10));

  Future<Pedido> crear() => pedidos.crear(
    const NuevoPedido(
      lineas: [LineaPedido(productoId: 'americano', cantidad: 1, precioUnitario: 4000)],
      zonaId: 'labs',
      referencia: 'Entrada',
      metodo: MetodoPago.efectivo,
    ),
  );

  Future<void> comoAndres(Future<void> Function() accion) async {
    pedidos.usuarioActual = 'Andrés Ruiz';
    await accion();
    pedidos.usuarioActual = 'laura';
    await esperar();
  }

  List<EstadoPedido> cambios() =>
      estados.where((s) => s.cambio != null).map((s) => s.cambio!.estado).toList();

  test('Lo que ya había al abrir y el pedido nuevo no notifican', () async {
    await crear();
    bloc.add(MisPedidosStarted());
    await esperar();
    await crear();
    await esperar();
    expect(bloc.state.pedidosActivos!.length, 2);
    expect(cambios(), isEmpty);
  });

  test('Avisa cuando lo aceptan, sale y lo entregan', () async {
    final pedido = await crear();
    bloc.add(MisPedidosStarted());
    await esperar();

    await comoAndres(() => pedidos.tomar(pedido.id));
    await comoAndres(
      () => pedidos.cambiarEstado(
        pedido.id,
        actual: EstadoPedido.aceptado,
        nuevo: EstadoPedido.enCamino,
      ),
    );
    await comoAndres(
      () => pedidos.cambiarEstado(
        pedido.id,
        actual: EstadoPedido.enCamino,
        nuevo: EstadoPedido.entregado,
      ),
    );

    expect(cambios(), [EstadoPedido.aceptado, EstadoPedido.enCamino, EstadoPedido.entregado]);
    expect(bloc.state.pedidosActivos, isEmpty);
    expect(bloc.state.pedidosHistorial!.single.id, pedido.id);
    // El cambio no se arrastra: en la siguiente emisión ya no está.
    bloc.add(MisPedidosTabChanged(false));
    await esperar();
    expect(bloc.state.cambio, isNull);
  });

  test('Si el cliente cancela no se notifica', () async {
    final pedido = await crear();
    bloc.add(MisPedidosStarted());
    await esperar();
    await pedidos.cancelar(pedido.id);
    await esperar();
    expect(cambios(), isEmpty);
    expect(bloc.state.pedidosHistorial!.single.estado, EstadoPedido.cancelado);
  });

  test('Cambiar de pestaña no vuelve a suscribir', () async {
    await crear();
    bloc.add(MisPedidosStarted());
    await esperar();
    bloc.add(MisPedidosTabChanged(false));
    await esperar();
    expect(bloc.state.activos, isFalse);
    expect(bloc.state.pedidos, isEmpty);
    bloc.add(MisPedidosTabChanged(true));
    await esperar();
    expect(bloc.state.pedidos.length, 1);
  });
}
