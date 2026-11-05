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

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
    catalogo = FakeCatalogoRepository();
    pedidos = FakePedidoRepository(catalogo);
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
      App(auth: auth, usuarios: usuarios, catalogo: catalogo, pedidos: pedidos),
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
    await tocar(tester, 'Volver a pedidos');

    expect(find.text('No hay pedidos pendientes'), findsOneWidget);
    await tocar(tester, 'Mis entregas');
    expect(find.text('No tienes entregas en curso'), findsOneWidget);
    await tocar(tester, 'Historial');
    expect(find.text('Pedido #${pedido.numero} · Laura G.'), findsOneWidget);
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
}
