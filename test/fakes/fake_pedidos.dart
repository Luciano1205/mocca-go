import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Catálogo en memoria con los datos del prototipo.
class FakeCatalogoRepository implements CatalogoRepository {
  final categorias = const [
    Categoria(id: 'cafes', nombre: 'Cafés'),
    Categoria(id: 'frias', nombre: 'Bebidas frías'),
    Categoria(id: 'snacks', nombre: 'Snacks'),
  ];

  final productos = <Producto>[
    const Producto(id: 'americano', categoriaId: 'cafes', nombre: 'Americano', precio: 4000),
    const Producto(id: 'capuchino', categoriaId: 'cafes', nombre: 'Capuchino', precio: 6500),
    const Producto(id: 'mocca', categoriaId: 'cafes', nombre: 'Mocca', precio: 7500),
    const Producto(id: 'helado', categoriaId: 'frias', nombre: 'Café helado', precio: 6000),
    const Producto(id: 'pandebono', categoriaId: 'snacks', nombre: 'Pandebono', precio: 3000),
    const Producto(
      id: 'croissant',
      categoriaId: 'snacks',
      nombre: 'Croissant',
      precio: 4500,
      disponible: false,
    ),
  ];

  final zonas = const [
    Zona(id: 'biblioteca', nombre: 'Biblioteca · Edificio L'),
    Zona(id: 'labs', nombre: 'Laboratorios · Edificio M'),
  ];

  final entidades = const [
    EntidadPago(id: 'nequi', nombre: 'Nequi', datoDestino: '300 123 4567', titular: 'Mocca Go!'),
  ];

  @override
  Future<List<Categoria>> getCategorias() async => categorias;

  @override
  Future<List<Producto>> getProductos({String? categoriaId}) async => productos
      .where((p) => categoriaId == null || p.categoriaId == categoriaId)
      .toList();

  @override
  Future<List<Zona>> getZonas() async => zonas;

  @override
  Future<List<EntidadPago>> getEntidadesPago() async => entidades;
}

/// Pedidos en memoria. [usuarioActual] hace de la sesión: cambia de cliente
/// a domiciliario para probar las dos puntas del ciclo.
class FakePedidoRepository implements PedidoRepository {
  final FakeCatalogoRepository catalogo;
  final Map<String, Pedido> pedidos = {};
  final Map<String, String> clienteDe = {};
  final Map<String, String?> domiciliarioDe = {};
  String usuarioActual = 'laura';
  int _siguiente = 1001;

  FakePedidoRepository(this.catalogo);

  @override
  Future<Pedido> crear(NuevoPedido nuevo) async {
    final items = <ItemPedido>[];
    for (final linea in nuevo.lineas) {
      final p = catalogo.productos.firstWhere((p) => p.id == linea.productoId);
      if (!p.disponible) throw PedidoFailure('El producto ${p.nombre} está agotado');
      items.add(
        ItemPedido(
          nombre: p.nombre,
          precioUnitario: p.precio,
          cantidad: linea.cantidad,
          subtotal: p.precio * linea.cantidad,
        ),
      );
    }
    final total = items.fold(0, (s, i) => s + i.subtotal);
    final id = 'p$_siguiente';
    final ahora = DateTime.now();
    pedidos[id] = Pedido(
      id: id,
      numero: _siguiente++,
      estado: EstadoPedido.pendiente,
      clienteNombre: usuarioActual,
      zona: catalogo.zonas.firstWhere((z) => z.id == nuevo.zonaId).nombre,
      referencia: nuevo.referencia,
      nota: nuevo.nota,
      items: items,
      pago: PagoPedido(
        metodo: nuevo.metodo,
        valorEntregado: nuevo.valorEntregado,
        cambio: nuevo.valorEntregado == null ? 0 : nuevo.valorEntregado! - total,
      ),
      subtotal: total,
      total: total,
      creadoEn: ahora,
      historial: {EstadoPedido.pendiente: ahora},
    );
    clienteDe[id] = usuarioActual;
    domiciliarioDe[id] = null;
    return pedidos[id]!;
  }

  @override
  Future<List<Pedido>> misPedidos({required bool activos}) async => pedidos.values
      .where((p) => clienteDe[p.id] == usuarioActual && p.estado.activo == activos)
      .toList();

  @override
  Future<bool> cancelar(String pedidoId) async {
    final p = pedidos[pedidoId]!;
    if (clienteDe[pedidoId] != usuarioActual || p.estado != EstadoPedido.pendiente) {
      return false;
    }
    pedidos[pedidoId] = p.copyWith(estado: EstadoPedido.cancelado);
    return true;
  }

  @override
  Future<List<Pedido>> pendientes() async =>
      pedidos.values.where((p) => p.estado == EstadoPedido.pendiente).toList();

  @override
  Future<List<Pedido>> misEntregas({required bool activos}) async => pedidos.values
      .where((p) => domiciliarioDe[p.id] == usuarioActual && p.estado.activo == activos)
      .toList();

  @override
  Future<bool> tomar(String pedidoId) async {
    final p = pedidos[pedidoId]!;
    if (p.estado != EstadoPedido.pendiente) return false;
    domiciliarioDe[pedidoId] = usuarioActual;
    pedidos[pedidoId] = p.copyWith(
      estado: EstadoPedido.aceptado,
      domiciliarioNombre: usuarioActual,
    );
    return true;
  }

  @override
  Future<bool> cambiarEstado(
    String pedidoId, {
    required EstadoPedido actual,
    required EstadoPedido nuevo,
  }) async {
    final p = pedidos[pedidoId]!;
    if (domiciliarioDe[pedidoId] != usuarioActual || p.estado != actual) return false;
    pedidos[pedidoId] = p.copyWith(estado: nuevo);
    return true;
  }

  @override
  Future<Pedido> getPedido(String pedidoId) async {
    final p = pedidos[pedidoId];
    if (p == null) throw const PedidoFailure('No se pudo cargar el pedido.');
    return p;
  }
}
