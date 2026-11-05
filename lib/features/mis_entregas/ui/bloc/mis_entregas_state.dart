import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum MisEntregasStatus { initial, loading, success, failure }

/// Estado de Mis entregas: pestaña elegida y sus pedidos.
class MisEntregasState {
  final MisEntregasStatus status;
  final bool activos;
  final List<Pedido> pedidos;
  final String? errorMessage;

  const MisEntregasState({
    this.status = MisEntregasStatus.initial,
    this.activos = true,
    this.pedidos = const [],
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  MisEntregasState copyWith({
    MisEntregasStatus? status,
    bool? activos,
    List<Pedido>? pedidos,
    String? errorMessage,
  }) {
    return MisEntregasState(
      status: status ?? this.status,
      activos: activos ?? this.activos,
      pedidos: pedidos ?? this.pedidos,
      errorMessage: errorMessage,
    );
  }
}
