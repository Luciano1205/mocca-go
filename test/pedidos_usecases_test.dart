import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/catalogo/domain/usecases/get_productos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/crear_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_entregas_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_pedidos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/tomar_pedido_usecase.dart';

import 'fakes/fake_pedidos.dart';

void main() {
  late FakeCatalogoRepository catalogo;
  late FakePedidoRepository pedidos;

  setUp(() {
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
  });

  // 2 Capuchino + 1 Pandebono = $16.000, como en el prototipo.
  NuevoPedido pedidoDeLaura({
    MetodoPago metodo = MetodoPago.efectivo,
    int? valorEntregado,
    String? entidadPagoId,
    String referencia = 'Segundo piso',
  }) {
    return NuevoPedido(
      lineas: const [
        LineaPedido(productoId: 'capuchino', cantidad: 2, precioUnitario: 6500),
        LineaPedido(productoId: 'pandebono', cantidad: 1, precioUnitario: 3000),
      ],
      zonaId: 'biblioteca',
      referencia: referencia,
      metodo: metodo,
      valorEntregado: valorEntregado,
      entidadPagoId: entidadPagoId,
    );
  }

  test('Menú filtrado por categoría', () async {
    final snacks = await GetProductosUseCase(catalogo)(categoriaId: 'snacks');
    expect(snacks.map((p) => p.nombre), ['Pandebono', 'Croissant']);
    expect((await GetProductosUseCase(catalogo)()).length, 6);
  });

  test('Crear pedido: queda pendiente, con total y cambio', () async {
    final pedido = await CrearPedidoUseCase(pedidos)(pedidoDeLaura(valorEntregado: 20000));
    expect(pedido.estado, EstadoPedido.pendiente);
    expect(pedido.total, 16000);
    expect(pedido.pago!.cambio, 4000);
    expect(pedido.resumenItems, '2 Capuchino · 1 Pandebono');
  });

  test('Crear pedido: validaciones antes de ir a la base de datos', () async {
    final crear = CrearPedidoUseCase(pedidos);
    await expectLater(
      crear(pedidoDeLaura(referencia: '   ')),
      throwsA(isA<PedidoFailure>()),
    );
    await expectLater(
      crear(pedidoDeLaura(valorEntregado: 10000)),
      throwsA(isA<PedidoFailure>()),
    );
    await expectLater(
      crear(pedidoDeLaura(metodo: MetodoPago.transferencia)),
      throwsA(isA<PedidoFailure>()),
    );
    await expectLater(
      crear(
        const NuevoPedido(
          lineas: [],
          zonaId: 'biblioteca',
          referencia: 'x',
          metodo: MetodoPago.efectivo,
        ),
      ),
      throwsA(isA<PedidoFailure>()),
    );
    expect(pedidos.pedidos, isEmpty);
  });

  test('Crear pedido: un producto agotado falla', () async {
    await expectLater(
      CrearPedidoUseCase(pedidos)(
        const NuevoPedido(
          lineas: [LineaPedido(productoId: 'croissant', cantidad: 1, precioUnitario: 4500)],
          zonaId: 'biblioteca',
          referencia: 'x',
          metodo: MetodoPago.efectivo,
        ),
      ),
      throwsA(isA<PedidoFailure>()),
    );
  });

  test('Ciclo completo: pendiente → aceptado → en camino → entregado', () async {
    final creado = await CrearPedidoUseCase(pedidos)(pedidoDeLaura());

    pedidos.usuarioActual = 'andres';
    expect((await GetPedidosPendientesUseCase(pedidos)()).single.id, creado.id);

    var pedido = await TomarPedidoUseCase(pedidos)(creado.id);
    expect(pedido.estado, EstadoPedido.aceptado);
    expect(await GetPedidosPendientesUseCase(pedidos)(), isEmpty);
    expect((await GetMisEntregasUseCase(pedidos)(activos: true)).single.id, creado.id);

    pedido = await AvanzarPedidoUseCase(pedidos)(pedido);
    expect(pedido.estado, EstadoPedido.enCamino);
    pedido = await AvanzarPedidoUseCase(pedidos)(pedido);
    expect(pedido.estado, EstadoPedido.entregado);
    await expectLater(AvanzarPedidoUseCase(pedidos)(pedido), throwsA(isA<PedidoFailure>()));

    pedidos.usuarioActual = 'laura';
    expect(await GetMisPedidosUseCase(pedidos)(activos: true), isEmpty);
    final historial = await GetMisPedidosUseCase(pedidos)(activos: false);
    expect(historial.single.domiciliarioNombre, 'andres');
  });

  test('Tomar un pedido que otro ya tomó da PedidoYaTomadoFailure', () async {
    final creado = await CrearPedidoUseCase(pedidos)(pedidoDeLaura());
    pedidos.usuarioActual = 'andres';
    await TomarPedidoUseCase(pedidos)(creado.id);
    pedidos.usuarioActual = 'pedro';
    await expectLater(
      TomarPedidoUseCase(pedidos)(creado.id),
      throwsA(isA<PedidoYaTomadoFailure>()),
    );
  });

  test('Cancelar: solo mientras está pendiente', () async {
    final uno = await CrearPedidoUseCase(pedidos)(pedidoDeLaura());
    final cancelado = await CancelarPedidoUseCase(pedidos)(uno.id);
    expect(cancelado.estado, EstadoPedido.cancelado);

    final dos = await CrearPedidoUseCase(pedidos)(pedidoDeLaura());
    pedidos.usuarioActual = 'andres';
    await TomarPedidoUseCase(pedidos)(dos.id);
    pedidos.usuarioActual = 'laura';
    await expectLater(
      CancelarPedidoUseCase(pedidos)(dos.id),
      throwsA(isA<PedidoFailure>()),
    );
  });

  test('Estados: siguiente y activos', () {
    expect(EstadoPedido.desde('en_camino'), EstadoPedido.enCamino);
    expect(EstadoPedido.aceptado.siguiente, EstadoPedido.enCamino);
    expect(EstadoPedido.entregado.siguiente, isNull);
    expect(EstadoPedido.cancelado.activo, isFalse);
  });
}
