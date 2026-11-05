import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';

enum MetodoPago { efectivo, transferencia }

/// Una línea del pedido, con el nombre y precio de cuando se pidió.
class ItemPedido {
  final String nombre;
  final int precioUnitario;
  final int cantidad;
  final int subtotal;

  const ItemPedido({
    required this.nombre,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });
}

/// Cómo se paga el pedido (tabla `pago`).
class PagoPedido {
  final MetodoPago metodo;

  /// Billete con el que paga en efectivo; null si es valor exacto.
  final int? valorEntregado;
  final int cambio;

  /// Solo transferencia: a dónde se transfiere.
  final String? entidadNombre;
  final String? entidadDato;
  final String? entidadTitular;

  const PagoPedido({
    required this.metodo,
    this.valorEntregado,
    this.cambio = 0,
    this.entidadNombre,
    this.entidadDato,
    this.entidadTitular,
  });

  /// "Efectivo · Valor exacto", "Efectivo" o "Transferencia · Nequi".
  String get resumen {
    if (metodo == MetodoPago.transferencia) {
      return 'Transferencia · ${entidadNombre ?? ''}';
    }
    return valorEntregado == null ? 'Efectivo · Valor exacto' : 'Efectivo';
  }
}

/// Pedido con todo lo que muestran las pantallas de cliente y domiciliario.
class Pedido {
  final String id;
  final int numero;
  final EstadoPedido estado;
  final String clienteNombre;
  final double? clienteCalificacion;
  final String? domiciliarioNombre;
  final double? domiciliarioCalificacion;
  final String zona;
  final String referencia;
  final String? nota;
  final List<ItemPedido> items;
  final PagoPedido? pago;
  final int subtotal;
  final int costoDomicilio;
  final int total;
  final DateTime creadoEn;

  /// Cuándo llegó a cada estado (para la línea de tiempo del seguimiento).
  final Map<EstadoPedido, DateTime> historial;

  const Pedido({
    required this.id,
    required this.numero,
    required this.estado,
    required this.clienteNombre,
    this.clienteCalificacion,
    this.domiciliarioNombre,
    this.domiciliarioCalificacion,
    required this.zona,
    required this.referencia,
    this.nota,
    this.items = const [],
    this.pago,
    required this.subtotal,
    this.costoDomicilio = 0,
    required this.total,
    required this.creadoEn,
    this.historial = const {},
  });

  /// "2 Capuchino · 1 Pandebono"
  String get resumenItems {
    return items.map((i) => '${i.cantidad} ${i.nombre}').join(' · ');
  }

  int get totalUnidades => items.fold(0, (suma, i) => suma + i.cantidad);

  Pedido copyWith({EstadoPedido? estado, String? domiciliarioNombre}) {
    return Pedido(
      id: id,
      numero: numero,
      estado: estado ?? this.estado,
      clienteNombre: clienteNombre,
      clienteCalificacion: clienteCalificacion,
      domiciliarioNombre: domiciliarioNombre ?? this.domiciliarioNombre,
      domiciliarioCalificacion: domiciliarioCalificacion,
      zona: zona,
      referencia: referencia,
      nota: nota,
      items: items,
      pago: pago,
      subtotal: subtotal,
      costoDomicilio: costoDomicilio,
      total: total,
      creadoEn: creadoEn,
      historial: historial,
    );
  }
}
