import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum PendientesStatus { initial, loading, success, failure }

/// Estado del feed: los pedidos que nadie ha tomado.
class PendientesState {
  final PendientesStatus status;
  final List<Pedido> pedidos;
  final String? errorMessage;

  const PendientesState({
    this.status = PendientesStatus.initial,
    this.pedidos = const [],
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  PendientesState copyWith({
    PendientesStatus? status,
    List<Pedido>? pedidos,
    String? errorMessage,
  }) {
    return PendientesState(
      status: status ?? this.status,
      pedidos: pedidos ?? this.pedidos,
      errorMessage: errorMessage,
    );
  }
}
