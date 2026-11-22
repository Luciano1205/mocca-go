import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum PendientesStatus { initial, loading, success, failure }

/// Estado del feed: los pedidos que nadie ha tomado.
class PendientesState {
  final PendientesStatus status;
  final List<Pedido> pedidos;
  final String? errorMessage;

  /// El pedido que acaba de llegar, para la notificación (14b). Solo viene
  /// en la emisión en que aparece; no cuenta los que ya estaban al abrir.
  final Pedido? nuevo;

  const PendientesState({
    this.status = PendientesStatus.initial,
    this.pedidos = const [],
    this.errorMessage,
    this.nuevo,
  });

  /// [errorMessage] y [nuevo] no se arrastran: si no se pasan, quedan vacíos.
  PendientesState copyWith({
    PendientesStatus? status,
    List<Pedido>? pedidos,
    String? errorMessage,
    Pedido? nuevo,
  }) {
    return PendientesState(
      status: status ?? this.status,
      pedidos: pedidos ?? this.pedidos,
      errorMessage: errorMessage,
      nuevo: nuevo,
    );
  }
}
