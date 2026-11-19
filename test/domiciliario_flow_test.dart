import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_state.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_pedidos.dart';
import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;
  late FakeCatalogoRepository catalogo;
  late FakePedidoRepository pedidos;
  late FakeCalificacionRepository calificaciones;

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
    calificaciones = FakeCalificacionRepository();
  });

  /// Laura (cliente) deja un pedido de $16.000 pendiente.
  Future<Pedido> pedidoDeLaura() {
    pedidos.usuarioActual = 'Laura Gómez';
    return pedidos.crear(
      const NuevoPedido(
        lineas: [
          LineaPedido(productoId: 'capuchino', cantidad: 2, precioUnitario: 6500),
          LineaPedido(productoId: 'pandebono', cantidad: 1, precioUnitario: 3000),
        ],
        zonaId: 'biblioteca',
        referencia: 'Piso 2, junto a la ventana',
        metodo: MetodoPago.efectivo,
        valorEntregado: 20000,
      ),
    );
  }

  /// Abre la app con la sesión de Andrés (domiciliario) ya iniciada.
  Future<void> abrirComoAndres(WidgetTester tester) async {
    const email = 'andres@icesi.edu.co';
    auth.passwords[email] = '123456';
    auth.ids[email] = 'id-andres';
    auth.sessionUserId = 'id-andres';
    usuarios.usuarios['id-andres'] = const Usuario(
      id: 'id-andres',
      nombre: 'Andrés Ruiz',
      correo: email,
      rol: Rol.proveedor,
    );
    pedidos.usuarioActual = 'andres';
    await tester.pumpWidget(
      App(
        auth: auth,
        usuarios: usuarios,
        catalogo: catalogo,
        pedidos: pedidos,
        calificaciones: calificaciones,
        reclamos: FakeReclamoRepository(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    await tester.tap(find.text(texto));
    await tester.pumpAndSettle();
  }

  testWidgets('Sin pedidos muestra 14c', (tester) async {
    await abrirComoAndres(tester);
    expect(find.text('No hay pedidos pendientes'), findsOneWidget);
  });

  testWidgets('El pedido nuevo aparece solo, sin recargar (14c → 14)', (tester) async {
    await abrirComoAndres(tester);
    expect(find.text('No hay pedidos pendientes'), findsOneWidget);

    await pedidoDeLaura();
    await tester.pumpAndSettle();
    expect(find.text('1 pedido esperando domiciliario'), findsOneWidget);
  });

  testWidgets('Toma un pedido y lo entrega (14 → 15 → 17 → 17b → 17c)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoAndres(tester);

    expect(find.text('1 pedido esperando domiciliario'), findsOneWidget);
    expect(find.text('Laura G. · Efectivo'), findsOneWidget);
    await tocar(tester, 'Biblioteca · Edificio L');

    expect(find.text('Pedido #${pedido.numero}'), findsOneWidget);
    expect(find.text('Laura Gómez'), findsOneWidget);
    await tocar(tester, 'Tomar pedido');

    expect(pedidos.pedidos[pedido.id]!.estado, EstadoPedido.aceptado);
    expect(find.text('Salir a entregar'), findsOneWidget);
    await tocar(tester, 'Salir a entregar');

    expect(find.text('Marcar como entregado'), findsOneWidget);
    await tocar(tester, 'Marcar como entregado');

    expect(pedidos.pedidos[pedido.id]!.estado, EstadoPedido.entregado);
    expect(find.text('Entrega completada'), findsOneWidget);

    // 18 · Calificar cliente se abre solo al entregar.
    expect(find.text('¿Cómo te fue con Laura?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('estrella-5')));
    await tester.pump();
    await tocar(tester, 'Enviar calificación');
    expect(calificaciones.dadas[pedido.id], 5);
    expect(find.text('Calificaste a Laura'), findsOneWidget);
    await tocar(tester, 'Volver a pedidos');

    expect(find.text('No hay pedidos pendientes'), findsOneWidget);
    await tocar(tester, 'Mis entregas');
    expect(find.text('No tienes entregas en curso'), findsOneWidget);
    await tocar(tester, 'Historial');
    expect(find.text('Pedido #${pedido.numero} · Laura G.'), findsOneWidget);
  });

  testWidgets('"Ahora no" deja calificar después desde 17c (18)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoAndres(tester);
    await tocar(tester, 'Biblioteca · Edificio L');
    await tocar(tester, 'Tomar pedido');
    await tocar(tester, 'Salir a entregar');
    await tocar(tester, 'Marcar como entregado');

    await tocar(tester, 'Ahora no');
    expect(calificaciones.dadas, isEmpty);
    await tocar(tester, 'Calificar a Laura');
    await tester.tap(find.byKey(const Key('estrella-4')));
    await tester.pump();
    await tocar(tester, 'Enviar calificación');
    expect(calificaciones.dadas[pedido.id], 4);
    expect(find.text('Calificar a Laura'), findsNothing);
  });

  testWidgets('Marca un producto como agotado (19)', (tester) async {
    await abrirComoAndres(tester);
    await tocar(tester, 'Productos');
    expect(find.text('Americano'), findsOneWidget);

    await tester.tap(find.byKey(const Key('switch-americano')));
    await tester.pumpAndSettle();
    expect(catalogo.productos.firstWhere((p) => p.id == 'americano').disponible, isFalse);
    expect(find.textContaining('Agotado'), findsWidgets);
  });

  testWidgets('Edita su nombre y descripción (20b)', (tester) async {
    await abrirComoAndres(tester);
    await tocar(tester, 'Perfil');
    await tocar(tester, 'Editar perfil');
    expect(find.text('Rol y calificación no se pueden editar'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Andrés Felipe Ruiz');
    await tester.enterText(find.byType(TextField).at(1), 'Domiciliario de las tardes');
    await tocar(tester, 'Guardar cambios');

    expect(usuarios.usuarios['id-andres']!.nombre, 'Andrés Felipe Ruiz');
    expect(find.text('Andrés Felipe Ruiz'), findsOneWidget);
    expect(find.text('Domiciliario de las tardes'), findsOneWidget);

    // Se mantiene al cambiar de pestaña.
    await tocar(tester, 'Pedidos');
    await tocar(tester, 'Perfil');
    expect(find.text('Andrés Felipe Ruiz'), findsOneWidget);
  });

  testWidgets('Si otro lo tomó primero muestra 15b', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoAndres(tester);
    await tocar(tester, 'Biblioteca · Edificio L');

    // Pedro lo toma mientras Andrés mira el detalle.
    pedidos.usuarioActual = 'pedro';
    await pedidos.tomar(pedido.id);
    pedidos.usuarioActual = 'andres';

    await tocar(tester, 'Tomar pedido');
    expect(find.text('Este pedido ya fue tomado'), findsOneWidget);
    await tocar(tester, 'Volver a pedidos');
    expect(find.text('No hay pedidos pendientes'), findsOneWidget);
  });

  test('El Bloc marca como nuevo solo lo que llega después de abrir (14b)', () async {
    final viejo = await pedidoDeLaura();
    final bloc = PendientesBloc(WatchPedidosPendientesUseCase(pedidos))
      ..add(PendientesStarted());
    final estados = <PendientesState>[];
    final sub = bloc.stream.listen(estados.add);
    await Future<void>.delayed(Duration.zero);

    final nuevo = await pedidoDeLaura();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    await bloc.close();

    final listos = estados.where((s) => s.status == PendientesStatus.success).toList();
    expect(listos.first.pedidos.map((p) => p.id), [viejo.id]);
    expect(listos.first.nuevo, isNull);
    expect(listos.last.pedidos.length, 2);
    expect(listos.last.nuevo!.id, nuevo.id);
  });
}
