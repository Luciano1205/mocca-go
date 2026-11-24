import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

enum MisPedidosStatus { initial, loading, success, failure }

/// Estado de Mis pedidos: las dos listas en tiempo real y la pestaña elegida.
class MisPedidosState {
  final MisPedidosStatus status;
  final bool activos;

  /// null hasta que llega la primera emisión de cada Stream.
  final List<Pedido>? pedidosActivos;
  final List<Pedido>? pedidosHistorial;
  final String? errorMessage;

  /// Pedido que el domiciliario acaba de aceptar, sacar a entregar o
  /// entregar, para la notificación (11b). Solo viene en esa emisión.
  final Pedido? cambio;

  const MisPedidosState({
    this.status = MisPedidosStatus.initial,
    this.activos = true,
    this.pedidosActivos,
    this.pedidosHistorial,
    this.errorMessage,
    this.cambio,
  });

  /// La lista de la pestaña elegida.
  List<Pedido> get pedidos => (activos ? pedidosActivos : pedidosHistorial) ?? const [];

  /// La pestaña elegida todavía no recibe su primera lista.
  bool get cargando => (activos ? pedidosActivos : pedidosHistorial) == null;

  /// [errorMessage] y [cambio] no se arrastran: si no se pasan, quedan vacíos.
  MisPedidosState copyWith({
    MisPedidosStatus? status,
    bool? activos,
    List<Pedido>? pedidosActivos,
    List<Pedido>? pedidosHistorial,
    String? errorMessage,
    Pedido? cambio,
  }) {
    return MisPedidosState(
      status: status ?? this.status,
      activos: activos ?? this.activos,
      pedidosActivos: pedidosActivos ?? this.pedidosActivos,
      pedidosHistorial: pedidosHistorial ?? this.pedidosHistorial,
      errorMessage: errorMessage,
      cambio: cambio,
    );
  }
}
