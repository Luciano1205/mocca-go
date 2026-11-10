import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// [cancelado] es cuando el cliente acaba de cancelarlo desde esta pantalla.
enum SeguimientoStatus { initial, loading, success, cancelando, cancelado, failure }

class SeguimientoState {
  final SeguimientoStatus status;
  final Pedido pedido;
  final String? errorMessage;

  const SeguimientoState({
    this.status = SeguimientoStatus.initial,
    required this.pedido,
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  SeguimientoState copyWith({SeguimientoStatus? status, Pedido? pedido, String? errorMessage}) {
    return SeguimientoState(
      status: status ?? this.status,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
    );
  }
}
