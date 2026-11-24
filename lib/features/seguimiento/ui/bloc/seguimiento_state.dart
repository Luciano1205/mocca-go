import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// [cancelado] es cuando el cliente acaba de cancelarlo desde esta pantalla.
enum SeguimientoStatus { initial, loading, success, cancelando, cancelado, calificando, failure }

class SeguimientoState {
  final SeguimientoStatus status;
  final Pedido pedido;
  final String? errorMessage;

  /// Estrellas que el cliente le dio al domiciliario; null si aún no califica.
  final int? miCalificacion;

  /// true solo en la emisión en que el pedido llega a Entregado: la pantalla
  /// abre la hoja para calificar (12).
  final bool pedirCalificacion;

  const SeguimientoState({
    this.status = SeguimientoStatus.initial,
    required this.pedido,
    this.errorMessage,
    this.miCalificacion,
    this.pedirCalificacion = false,
  });

  /// [errorMessage] y [pedirCalificacion] no se arrastran.
  SeguimientoState copyWith({
    SeguimientoStatus? status,
    Pedido? pedido,
    String? errorMessage,
    int? miCalificacion,
    bool pedirCalificacion = false,
  }) {
    return SeguimientoState(
      status: status ?? this.status,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
      miCalificacion: miCalificacion ?? this.miCalificacion,
      pedirCalificacion: pedirCalificacion,
    );
  }
}
