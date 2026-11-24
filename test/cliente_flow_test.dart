import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_complementos.dart';
import 'fakes/fake_dependencias.dart';
import 'fakes/fake_pedidos.dart';
import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;
  late FakeCatalogoRepository catalogo;
  late FakePedidoRepository pedidos;
  late FakeCalificacionRepository calificaciones;
  late FakeReclamoRepository reclamos;
  const laura = 'Laura Gómez';

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
    calificaciones = FakeCalificacionRepository();
    reclamos = FakeReclamoRepository();
  });

  /// Abre la app con la sesión de Laura (cliente) ya iniciada.
  Future<void> abrirComoLaura(WidgetTester tester) async {
    const email = 'laura@icesi.edu.co';
    auth.passwords[email] = '123456';
    auth.ids[email] = 'id-laura';
    auth.sessionUserId = 'id-laura';
    usuarios.usuarios['id-laura'] = const Usuario(
      id: 'id-laura',
      nombre: laura,
      correo: email,
      rol: Rol.cliente,
    );
    pedidos.usuarioActual = laura;
    // Pantalla alta para que el menú quepa sin desplazarse, y ancha porque
    // la fuente de las pruebas ocupa más que Inter.
    tester.view.physicalSize = const Size(2400, 3000);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    registrarFakes(
      auth: auth,
      usuarios: usuarios,
      catalogo: catalogo,
      pedidos: pedidos,
      calificaciones: calificaciones,
      reclamos: reclamos,
    );
    await tester.pumpWidget(const App());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  /// Laura deja un pedido de $6.500 pendiente sin pasar por la app.
  Future<Pedido> pedidoDeLaura() {
    pedidos.usuarioActual = laura;
    return pedidos.crear(
      const NuevoPedido(
        lineas: [LineaPedido(productoId: 'capuchino', cantidad: 1, precioUnitario: 6500)],
        zonaId: 'biblioteca',
        referencia: 'Piso 2',
        metodo: MetodoPago.efectivo,
      ),
    );
  }

  Future<void> tocar(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tocarTexto(WidgetTester tester, String texto) =>
      tocar(tester, find.text(texto).last);

  /// En el menú: agrega 2 capuchinos y 1 pandebono ($16.000) y abre el carrito.
  Future<void> llenarCarrito(WidgetTester tester) async {
    await tocar(tester, find.byTooltip('Agregar Capuchino'));
    await tocar(tester, find.byTooltip('Agregar uno'));
    await tocar(tester, find.byTooltip('Agregar Pandebono'));
    await tocarTexto(tester, 'Ver carrito');
  }

  /// En Datos de entrega: elige la zona (08b) y escribe la referencia.
  Future<void> llenarEntrega(WidgetTester tester) async {
    await tocarTexto(tester, 'Elige la zona');
    await tocarTexto(tester, 'Biblioteca · Edificio L');
    await tester.enterText(find.byType(TextField).at(0), 'Piso 2, junto a la ventana');
    await tester.pumpAndSettle();
  }

  testWidgets('El menú muestra los productos y el agotado no se puede pedir', (tester) async {
    await abrirComoLaura(tester);
    expect(find.text('Hola, Laura'), findsOneWidget);
    expect(find.text('Capuchino'), findsOneWidget);
    expect(find.text('\$6.500'), findsOneWidget);
    expect(find.text('Agotado'), findsOneWidget);
    expect(find.byTooltip('Agregar Croissant'), findsNothing);
    // Sin nada en el carrito no aparece la barra.
    expect(find.text('Ver carrito'), findsNothing);
  });

  testWidgets('Los chips filtran por categoría', (tester) async {
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Snacks');
    expect(find.text('Pandebono'), findsOneWidget);
    expect(find.text('Capuchino'), findsNothing);

    await tocarTexto(tester, 'Todos');
    expect(find.text('Capuchino'), findsOneWidget);
  });

  testWidgets('El carrito suma, resta y se vacía (07 → 07b)', (tester) async {
    await abrirComoLaura(tester);
    await tocar(tester, find.byTooltip('Agregar Capuchino'));
    await tocar(tester, find.byTooltip('Agregar uno'));
    await tocar(tester, find.byTooltip('Agregar Pandebono'));
    expect(find.text('\$16.000'), findsOneWidget);

    await tocarTexto(tester, 'Ver carrito');
    expect(find.text('Tu carrito'), findsOneWidget);
    expect(find.text('\$13.000'), findsOneWidget); // 2 capuchinos
    expect(find.text('\$16.000'), findsWidgets);

    await tocar(tester, find.byTooltip('Quitar uno').first);
    expect(find.text('\$9.500'), findsWidgets);

    await tocarTexto(tester, 'Vaciar');
    expect(find.text('Tu carrito está vacío'), findsOneWidget);
    await tocarTexto(tester, 'Ver menú');
    expect(find.text('Ver carrito'), findsNothing);
  });

  testWidgets('Datos de entrega valida zona, referencia y otro valor', (tester) async {
    await abrirComoLaura(tester);
    await llenarCarrito(tester);
    await tocarTexto(tester, 'Continuar');

    await tocarTexto(tester, 'Confirmar pedido · \$16.000');
    expect(find.text('Elige la zona de entrega'), findsOneWidget);
    expect(find.text('Escribe una referencia para encontrarte'), findsOneWidget);
    expect(pedidos.pedidos, isEmpty);

    await llenarEntrega(tester);
    await tocarTexto(tester, 'Otro valor');
    await tester.enterText(find.byType(TextField).last, '10000');
    await tocarTexto(tester, 'Confirmar pedido · \$16.000');
    expect(find.text('Debe ser de al menos \$16.000'), findsOneWidget);
    expect(pedidos.pedidos, isEmpty);
  });

  testWidgets('Pide en efectivo con \$20.000 y ve el seguimiento (08c → 09 → 11)', (tester) async {
    await abrirComoLaura(tester);
    await llenarCarrito(tester);
    await tocarTexto(tester, 'Continuar');
    await llenarEntrega(tester);

    await tocarTexto(tester, 'Con \$20.000');
    expect(find.text('Tu cambio: \$4.000'), findsOneWidget);
    await tocarTexto(tester, 'Confirmar pedido · \$16.000');

    expect(find.text('¡Pedido enviado!'), findsOneWidget);
    final pedido = pedidos.pedidos.values.single;
    expect(pedido.pago!.valorEntregado, 20000);
    expect(pedido.pago!.cambio, 4000);
    expect(pedido.referencia, 'Piso 2, junto a la ventana');

    await tocarTexto(tester, 'Ver seguimiento');
    expect(find.text('Pedido #${pedido.numero}'), findsOneWidget);
    expect(find.text('Pedido recibido'), findsOneWidget);
    expect(find.text('Buscando domiciliario...'), findsOneWidget);

    // Al volver, el carrito quedó vacío.
    await tocar(tester, find.byIcon(Icons.chevron_left));
    expect(find.text('Hola, Laura'), findsOneWidget);
    expect(find.text('Ver carrito'), findsNothing);
  });

  testWidgets('Pide por transferencia a Nequi (08d)', (tester) async {
    await abrirComoLaura(tester);
    await tocar(tester, find.byTooltip('Agregar Capuchino'));
    await tocarTexto(tester, 'Ver carrito');
    await tocarTexto(tester, 'Continuar');
    await llenarEntrega(tester);

    await tocarTexto(tester, 'Transferencia');
    await tocarTexto(tester, 'Confirmar pedido · \$6.500');
    expect(find.text('Elige a qué cuenta vas a transferir'), findsOneWidget);

    await tocarTexto(tester, 'Nequi');
    expect(find.text('Transfiere \$6.500 a Nequi'), findsOneWidget);
    await tocarTexto(tester, 'Confirmar pedido · \$6.500');

    expect(find.text('¡Pedido enviado!'), findsOneWidget);
    expect(pedidos.pedidos.values.single.pago!.metodo, MetodoPago.transferencia);
  });

  testWidgets('Cancela un pedido pendiente y lo ve en el historial (11c → 11e)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    expect(find.text('Pedido #${pedido.numero}'), findsOneWidget);
    await tocarTexto(tester, 'Pedido #${pedido.numero}');

    await tocarTexto(tester, 'Cancelar pedido');
    expect(find.text('¿Cancelar el pedido?'), findsOneWidget);
    await tocarTexto(tester, 'No, seguir esperando');
    expect(pedidos.pedidos[pedido.id]!.estado, EstadoPedido.pendiente);

    await tocarTexto(tester, 'Cancelar pedido');
    await tocarTexto(tester, 'Sí, cancelar');
    expect(pedidos.pedidos[pedido.id]!.estado, EstadoPedido.cancelado);
    expect(find.text('Pedido cancelado'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsNothing);

    await tocar(tester, find.byIcon(Icons.chevron_left));
    expect(find.text('No tienes pedidos en curso'), findsOneWidget);
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    expect(find.text('Pedido cancelado'), findsOneWidget);
  });

  /// Andrés (domiciliario) toma el pedido y lo lleva hasta [hasta].
  Future<void> andresLleva(Pedido pedido, EstadoPedido hasta) async {
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.tomar(pedido.id);
    if (hasta != EstadoPedido.aceptado) {
      await pedidos.cambiarEstado(
        pedido.id,
        actual: EstadoPedido.aceptado,
        nuevo: EstadoPedido.enCamino,
      );
    }
    if (hasta == EstadoPedido.entregado) {
      await pedidos.cambiarEstado(
        pedido.id,
        actual: EstadoPedido.enCamino,
        nuevo: EstadoPedido.entregado,
      );
    }
    pedidos.usuarioActual = laura;
  }

  testWidgets('Mis pedidos cambia solo cuando el domiciliario lo toma (10)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    expect(find.text('Buscando domiciliario'), findsOneWidget);

    await andresLleva(pedido, EstadoPedido.aceptado);
    await tester.pumpAndSettle();
    expect(find.text('Domiciliario: Andrés R.'), findsOneWidget);

    // Al entregarlo pasa solo de Activos a Historial.
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.aceptado,
      nuevo: EstadoPedido.enCamino,
    );
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.enCamino,
      nuevo: EstadoPedido.entregado,
    );
    await tester.pumpAndSettle();
    expect(find.text('No tienes pedidos en curso'), findsOneWidget);
    await tocarTexto(tester, 'Historial');
    expect(find.text('Pedido #${pedido.numero}'), findsOneWidget);
  });

  testWidgets('El seguimiento avanza solo y ya no deja cancelar (11 → 11b)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    expect(find.text('Cancelar pedido'), findsOneWidget);
    expect(find.text('Buscando domiciliario...'), findsOneWidget);

    // Andrés lo toma mientras Laura mira el seguimiento.
    await andresLleva(pedido, EstadoPedido.aceptado);
    await tester.pumpAndSettle();
    expect(find.text('Andrés Ruiz'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsNothing);

    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.aceptado,
      nuevo: EstadoPedido.enCamino,
    );
    await tester.pumpAndSettle();
    expect(find.text('Andrés R. va en camino'), findsOneWidget);
  });

  testWidgets('Al entregarse pide calificar y "Ahora no" deja hacerlo después (12)', (
    tester,
  ) async {
    final pedido = await pedidoDeLaura();
    await andresLleva(pedido, EstadoPedido.enCamino);
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');

    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.enCamino,
      nuevo: EstadoPedido.entregado,
    );
    await tester.pumpAndSettle();
    expect(find.text('¡Tu pedido llegó!'), findsOneWidget);
    expect(find.text('¿Cómo te atendió Andrés?'), findsOneWidget);

    await tocarTexto(tester, 'Ahora no');
    expect(calificaciones.dadas, isEmpty);
    await tocarTexto(tester, 'Calificar a Andrés');
    await tester.tap(find.byKey(const Key('estrella-5')));
    await tester.pump();
    await tocarTexto(tester, 'Enviar calificación');
    expect(calificaciones.dadas[pedido.id], 5);
    expect(find.text('Calificaste a Andrés'), findsOneWidget);
    expect(find.text('Calificar a Andrés'), findsNothing);
  });

  testWidgets('Califica al domiciliario desde el historial (11d)', (tester) async {
    final pedido = await pedidoDeLaura();
    await andresLleva(pedido, EstadoPedido.entregado);
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');

    // Ya estaba entregado al abrir: no salta la hoja sola.
    expect(find.text('¡Tu pedido llegó!'), findsNothing);
    await tocarTexto(tester, 'Calificar a Andrés');
    await tester.tap(find.byKey(const Key('estrella-4')));
    await tester.pump();
    await tocarTexto(tester, 'Enviar calificación');
    expect(calificaciones.dadas[pedido.id], 4);
    expect(find.text('Calificaste a Andrés'), findsOneWidget);
  });

  testWidgets('Si ya calificó, el detalle muestra sus estrellas', (tester) async {
    final pedido = await pedidoDeLaura();
    await andresLleva(pedido, EstadoPedido.entregado);
    calificaciones.dadas[pedido.id] = 3;
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    expect(find.text('Calificaste a Andrés'), findsOneWidget);
    expect(find.text('Calificar a Andrés'), findsNothing);
  });

  testWidgets('El menú muestra un producto agotado al instante (06)', (tester) async {
    await abrirComoLaura(tester);
    expect(find.byTooltip('Agregar Americano'), findsOneWidget);

    await catalogo.cambiarDisponibilidad('americano', disponible: false);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Agregar Americano'), findsNothing);
    expect(find.text('Agotado'), findsNWidgets(2)); // Croissant y Americano
  });

  testWidgets('Un pedido entregado se ve en el historial (10b → 11d)', (tester) async {
    final pedido = await pedidoDeLaura();
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.tomar(pedido.id);
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.aceptado,
      nuevo: EstadoPedido.enCamino,
    );
    await pedidos.cambiarEstado(
      pedido.id,
      actual: EstadoPedido.enCamino,
      nuevo: EstadoPedido.entregado,
    );

    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    expect(find.text('No tienes pedidos en curso'), findsOneWidget);
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    expect(find.text('Pedido entregado'), findsOneWidget);
    expect(find.text('Andrés Ruiz'), findsOneWidget);
    expect(find.text('Total pagado'), findsOneWidget);
  });

  testWidgets('Reclamo de un pedido entregado: faltó un producto (21 → 21d)', (tester) async {
    final pedido = await pedidoDeLaura();
    await andresLleva(pedido, EstadoPedido.entregado);
    calificaciones.dadas[pedido.id] = 5;
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    await tocarTexto(tester, '¿Problema con tu pedido? Escríbenos');

    expect(find.text('¿Qué pasó?'), findsOneWidget);
    // Motivos de un pedido entregado, no los de uno en curso.
    expect(find.text('Mi pedido no ha llegado'), findsNothing);
    await tocarTexto(tester, 'Faltó un producto');

    expect(find.text('¿Qué producto? Puedes marcar varios.'), findsOneWidget);
    await tocarTexto(tester, 'Continuar'); // sin marcar nada no avanza
    expect(find.text('¿Cómo lo solucionamos?'), findsNothing);
    await tocarTexto(tester, '1 × Capuchino');
    await tocarTexto(tester, 'Continuar');

    expect(find.text('¿Cómo lo solucionamos?'), findsOneWidget);
    await tocarTexto(tester, 'Reenviar el pedido');

    expect(
      find.text('Registramos tu reclamo #R-101. Alguien del equipo te contactará pronto.'),
      findsOneWidget,
    );
    final reclamo = reclamos.abiertos.single;
    expect(reclamo.pedidoId, pedido.id);
    expect(reclamo.motivoId, 'falto');
    expect(reclamo.detalleIds, ['d${pedido.numero}-capuchino']);
    expect(reclamo.solucion, SolucionReclamo.reenviar);

    await tocarTexto(tester, 'Volver al pedido');
    expect(find.text('Pedido entregado'), findsOneWidget);
  });

  testWidgets('Reclamo de un pedido en curso desde el seguimiento (22 → 22b)', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    await tocar(tester, find.textContaining('Escríbenos', findRichText: true));

    expect(find.text('Faltó un producto'), findsNothing);
    await tocarTexto(tester, 'Mi pedido no ha llegado');
    // Este motivo no pide producto ni solución: se registra de una vez.
    expect(find.textContaining('Registramos tu reclamo #R-101'), findsOneWidget);
    expect(reclamos.abiertos.single.motivoId, 'no-llega');
    expect(reclamos.abiertos.single.detalleIds, isEmpty);
  });

  testWidgets('Un pedido cancelado no muestra el link de reclamos', (tester) async {
    final pedido = await pedidoDeLaura();
    await pedidos.cancelar(pedido.id);
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Historial');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');
    expect(find.text('Pedido cancelado'), findsOneWidget);
    expect(find.textContaining('Escríbenos', findRichText: true), findsNothing);
  });
}
