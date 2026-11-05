import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum GestionarPedidoStatus { initial, avanzando, failure }

class GestionarPedidoState {
  final GestionarPedidoStatus status;
  final Pedido pedido;
  final String? errorMessage;

  const GestionarPedidoState({
    this.status = GestionarPedidoStatus.initial,
    required this.pedido,
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  GestionarPedidoState copyWith({
    GestionarPedidoStatus? status,
    Pedido? pedido,
    String? errorMessage,
  }) {
    return GestionarPedidoState(
      status: status ?? this.status,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
    );
  }
}
