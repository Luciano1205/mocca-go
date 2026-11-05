import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Un producto del carrito: lo único que la app manda de cada línea.
/// Nombre y precio los copia la base de datos.
class LineaPedido {
  final String productoId;
  final int cantidad;
  final int precioUnitario;

  const LineaPedido({
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
  });

  int get subtotal => precioUnitario * cantidad;
}

/// Lo que arma el cliente entre el carrito y "Datos de entrega".
class NuevoPedido {
  final List<LineaPedido> lineas;
  final String zonaId;
  final String referencia;
  final String? nota;
  final MetodoPago metodo;

  /// Efectivo: billete con el que paga; null si es valor exacto.
  final int? valorEntregado;

  /// Transferencia: la entidad elegida.
  final String? entidadPagoId;

  const NuevoPedido({
    required this.lineas,
    required this.zonaId,
    required this.referencia,
    this.nota,
    required this.metodo,
    this.valorEntregado,
    this.entidadPagoId,
  });

  /// Total que ve el cliente. La base de datos lo vuelve a calcular con los
  /// precios reales, así que este valor solo sirve para validar en la app.
  int get total => lineas.fold(0, (suma, l) => suma + l.subtotal);
}
