import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_pedidos.dart';
import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;
  late FakeCatalogoRepository catalogo;
  late FakePedidoRepository pedidos;
  const laura = 'Laura Gómez';

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
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
    await tester.pumpWidget(
      App(auth: auth, usuarios: usuarios, catalogo: catalogo, pedidos: pedidos),
    );
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

  testWidgets('No puede cancelar si un domiciliario ya lo tomó', (tester) async {
    final pedido = await pedidoDeLaura();
    await abrirComoLaura(tester);
    await tocarTexto(tester, 'Mis pedidos');
    await tocarTexto(tester, 'Pedido #${pedido.numero}');

    // Andrés lo toma mientras Laura mira el seguimiento.
    pedidos.usuarioActual = 'Andrés Ruiz';
    await pedidos.tomar(pedido.id);
    pedidos.usuarioActual = laura;

    await tocarTexto(tester, 'Cancelar pedido');
    await tocarTexto(tester, 'Sí, cancelar');
    expect(find.text('Ya no se puede cancelar: un domiciliario tomó tu pedido.'), findsOneWidget);
    expect(find.text('Andrés Ruiz'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsNothing);
    expect(pedidos.pedidos[pedido.id]!.estado, EstadoPedido.aceptado);
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
}
