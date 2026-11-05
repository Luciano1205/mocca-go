import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// [yaTomado] es 15b: otro domiciliario lo tomó primero.
enum DetallePedidoStatus { initial, tomando, tomado, yaTomado, failure }

class DetallePedidoState {
  final DetallePedidoStatus status;
  final Pedido pedido;
  final String? errorMessage;

  const DetallePedidoState({
    this.status = DetallePedidoStatus.initial,
    required this.pedido,
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  DetallePedidoState copyWith({
    DetallePedidoStatus? status,
    Pedido? pedido,
    String? errorMessage,
  }) {
    return DetallePedidoState(
      status: status ?? this.status,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
    );
  }
}
