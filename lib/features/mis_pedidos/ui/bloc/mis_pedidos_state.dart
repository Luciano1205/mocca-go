import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum MisPedidosStatus { initial, loading, success, failure }

/// Estado de Mis pedidos: pestaña elegida y sus pedidos.
class MisPedidosState {
  final MisPedidosStatus status;
  final bool activos;
  final List<Pedido> pedidos;
  final String? errorMessage;

  const MisPedidosState({
    this.status = MisPedidosStatus.initial,
    this.activos = true,
    this.pedidos = const [],
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  MisPedidosState copyWith({
    MisPedidosStatus? status,
    bool? activos,
    List<Pedido>? pedidos,
    String? errorMessage,
  }) {
    return MisPedidosState(
      status: status ?? this.status,
      activos: activos ?? this.activos,
      pedidos: pedidos ?? this.pedidos,
      errorMessage: errorMessage,
    );
  }
}
