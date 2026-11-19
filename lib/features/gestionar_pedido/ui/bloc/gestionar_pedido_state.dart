import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum GestionarPedidoStatus { initial, avanzando, calificando, failure }

class GestionarPedidoState {
  final GestionarPedidoStatus status;
  final Pedido pedido;
  final String? errorMessage;

  /// Estrellas que el domiciliario le dio al cliente; null si aún no califica.
  final int? miCalificacion;

  /// true solo en la emisión en que el pedido pasa a Entregado: la pantalla
  /// abre la hoja para calificar (18).
  final bool pedirCalificacion;

  const GestionarPedidoState({
    this.status = GestionarPedidoStatus.initial,
    required this.pedido,
    this.errorMessage,
    this.miCalificacion,
    this.pedirCalificacion = false,
  });

  /// [errorMessage] y [pedirCalificacion] no se arrastran.
  GestionarPedidoState copyWith({
    GestionarPedidoStatus? status,
    Pedido? pedido,
    String? errorMessage,
    int? miCalificacion,
    bool pedirCalificacion = false,
  }) {
    return GestionarPedidoState(
      status: status ?? this.status,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
      miCalificacion: miCalificacion ?? this.miCalificacion,
      pedirCalificacion: pedirCalificacion,
    );
  }
}
