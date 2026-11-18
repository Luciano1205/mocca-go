import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/usecases/actualizar_perfil_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/errors/calificacion_failure.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/cambiar_disponibilidad_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/watch_productos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/crear_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/tomar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_pedidos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/errors/reclamo_failure.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/abrir_reclamo_usecase.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/get_motivos_reclamo_usecase.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_pedidos.dart';
import 'fakes/fake_repositories.dart';

/// Deja correr los avisos del Stream (como esperar a Supabase Realtime).
Future<void> esperar() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeCatalogoRepository catalogo;
  late FakePedidoRepository pedidos;

  setUp(() {
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
  });

  Future<Pedido> crearPedido() {
    return CrearPedidoUseCase(pedidos)(
      const NuevoPedido(
        lineas: [
          LineaPedido(productoId: 'mocca', cantidad: 1, precioUnitario: 7500),
          LineaPedido(productoId: 'pandebono', cantidad: 1, precioUnitario: 3000),
        ],
        zonaId: 'labs',
        referencia: 'Entrada',
        metodo: MetodoPago.efectivo,
      ),
    );
  }

  /// Laura pide y Andrés lo toma y lo entrega.
  Future<Pedido> pedidoEntregado() async {
    final pedido = await crearPedido();
    pedidos.usuarioActual = 'andres';
    await TomarPedidoUseCase(pedidos)(pedido.id);
    var p = await pedidos.getPedido(pedido.id);
    p = await AvanzarPedidoUseCase(pedidos)(p);
    p = await AvanzarPedidoUseCase(pedidos)(p);
    pedidos.usuarioActual = 'laura';
    return p;
  }

  group('Tiempo real', () {
    test('El feed recibe el pedido nuevo y lo pierde cuando lo toman', () async {
      final emitidos = <List<String>>[];
      final sub = WatchPedidosPendientesUseCase(pedidos)().listen(
        (lista) => emitidos.add(lista.map((p) => p.id).toList()),
      );
      await esperar();
      final pedido = await crearPedido();
      await esperar();
      pedidos.usuarioActual = 'andres';
      await TomarPedidoUseCase(pedidos)(pedido.id);
      await esperar();
      await sub.cancel();

      expect(emitidos, [
        <String>[],
        [pedido.id],
        <String>[],
      ]);
    });

    test('Mis pedidos ve el cambio de estado sin recargar', () async {
      final pedido = await crearPedido();
      final estados = <EstadoPedido>[];
      final sub = WatchMisPedidosUseCase(pedidos)(activos: true).listen(
        (lista) => estados.add(lista.single.estado),
      );
      await esperar();
      pedidos.usuarioActual = 'andres';
      await TomarPedidoUseCase(pedidos)(pedido.id);
      await esperar();
      await sub.cancel();

      expect(estados, [EstadoPedido.pendiente, EstadoPedido.aceptado]);
    });

    test('El menú ve el producto agotado al instante', () async {
      final disponibles = <bool>[];
      final sub = WatchProductosUseCase(catalogo)(categoriaId: 'cafes').listen(
        (lista) => disponibles.add(lista.firstWhere((p) => p.id == 'americano').disponible),
      );
      await esperar();
      await CambiarDisponibilidadUseCase(catalogo)('americano', disponible: false);
      await esperar();
      await sub.cancel();

      expect(disponibles, [true, false]);
    });
  });

  group('Calificaciones', () {
    test('Solo pedidos entregados y una vez', () async {
      final calificaciones = FakeCalificacionRepository();
      final calificar = CalificarUseCase(calificaciones);

      final pendiente = await crearPedido();
      await expectLater(calificar(pendiente, valor: 5), throwsA(isA<CalificacionFailure>()));

      final entregado = await pedidoEntregado();
      await expectLater(calificar(entregado, valor: 0), throwsA(isA<CalificacionFailure>()));
      await calificar(entregado, valor: 5);
      expect(await GetMiCalificacionUseCase(calificaciones)(entregado.id), 5);
      await expectLater(calificar(entregado, valor: 4), throwsA(isA<CalificacionFailure>()));
    });
  });

  group('Reclamos', () {
    test('Los motivos dependen del estado del pedido', () async {
      final motivos = GetMotivosReclamoUseCase(FakeReclamoRepository());
      final enCurso = await motivos(await crearPedido());
      expect(enCurso.every((m) => !m.paraEntregado), isTrue);
      final entregado = await motivos(await pedidoEntregado());
      expect(entregado.map((m) => m.texto), contains('Faltó un producto'));
    });

    test('Faltó un producto pide producto y solución', () async {
      final repo = FakeReclamoRepository();
      final abrir = AbrirReclamoUseCase(repo);
      final pedido = await pedidoEntregado();
      final falto = repo.motivos.firstWhere((m) => m.id == 'falto');

      await expectLater(abrir(pedido, motivo: falto), throwsA(isA<ReclamoFailure>()));
      await expectLater(
        abrir(pedido, motivo: falto, productos: [pedido.items.first]),
        throwsA(isA<ReclamoFailure>()),
      );

      final reclamo = await abrir(
        pedido,
        motivo: falto,
        productos: [pedido.items.first],
        solucion: SolucionReclamo.reenviar,
      );
      expect(reclamo.codigo, 'R-101');
      expect(repo.abiertos.single.detalleIds, [pedido.items.first.id]);
      expect(repo.abiertos.single.solucion, SolucionReclamo.reenviar);
    });
  });

  group('Perfil', () {
    test('Editar nombre y descripción', () async {
      final usuarios = FakeUsuarioRepository()
        ..usuarios['laura'] = const Usuario(
          id: 'laura',
          nombre: 'Laura',
          correo: 'laura@u.icesi.edu.co',
          rol: Rol.cliente,
          calificacionPromedio: 4.9,
        );
      final actualizar = ActualizarPerfilUseCase(usuarios);
      final laura = usuarios.usuarios['laura']!;

      await expectLater(actualizar(laura, nombre: '   '), throwsA(isA<AuthFailure>()));
      final nuevo = await actualizar(laura, nombre: ' Laura Gómez ', descripcion: '  ');
      expect(nuevo.nombre, 'Laura Gómez');
      expect(nuevo.descripcion, isNull);
      expect(nuevo.calificacionPromedio, 4.9);
    });
  });
}
