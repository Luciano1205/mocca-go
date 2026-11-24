import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_pedidos_usecase.dart';
import 'package:mocca_go/utils/reconexion.dart';

/// Pedidos del cliente en tiempo real (10 · Activos, 10b · Historial) y el
/// aviso de cambio de estado (11b).
///
/// Abre las dos suscripciones desde el inicio y no las cambia al cambiar de
/// pestaña. Solo el Bloc escucha los Streams y los cancela en [close].
class MisPedidosBloc extends Bloc<MisPedidosEvent, MisPedidosState> {
  final WatchMisPedidosUseCase _watchMisPedidos;

  /// Cuánto esperar para reconectar; solo cambia en las pruebas.
  final Duration espera;

  StreamSubscription<List<Pedido>>? _subActivos;
  StreamSubscription<List<Pedido>>? _subHistorial;

  /// Reconexión programada después de un error del Stream.
  Timer? _reconexion;

  /// Último estado conocido de cada pedido, de las dos listas. Un pedido que
  /// aparece por primera vez no notifica, así no se avisa de lo que ya había
  /// al abrir la app ni del pedido que el cliente acaba de crear.
  final Map<String, EstadoPedido> _conocidos = {};

  /// Estados que hace el domiciliario: los que se notifican.
  static const _notificables = {
    EstadoPedido.aceptado,
    EstadoPedido.enCamino,
    EstadoPedido.entregado,
  };

  MisPedidosBloc(this._watchMisPedidos, {this.espera = esperaReconexion})
    : super(const MisPedidosState()) {
    on<MisPedidosStarted>(_onStarted);
    on<MisPedidosTabChanged>(_onTabChanged);
    on<MisPedidosUpdated>(_onUpdated);
    on<MisPedidosStreamFailed>(_onStreamFailed);
  }

  void _onStarted(MisPedidosStarted event, Emitter<MisPedidosState> emit) {
    _reconexion?.cancel();
    emit(state.copyWith(status: MisPedidosStatus.loading));
    // Sin await: cancel() corta los avisos de inmediato, y en las pruebas
    // de widgets (tiempo simulado) esperar su Future no termina nunca.
    _subActivos?.cancel();
    _subHistorial?.cancel();
    _subActivos = _escuchar(activos: true);
    _subHistorial = _escuchar(activos: false);
  }

  StreamSubscription<List<Pedido>> _escuchar({required bool activos}) {
    return _watchMisPedidos(activos: activos).listen(
      (pedidos) => add(MisPedidosUpdated(activos: activos, pedidos: pedidos)),
      onError: (Object error) => add(MisPedidosStreamFailed(mensajeSinConexion)),
    );
  }

  void _onTabChanged(MisPedidosTabChanged event, Emitter<MisPedidosState> emit) {
    emit(state.copyWith(activos: event.activos));
  }

  void _onUpdated(MisPedidosUpdated event, Emitter<MisPedidosState> emit) {
    Pedido? cambio;
    for (final pedido in event.pedidos) {
      final antes = _conocidos[pedido.id];
      if (antes != null && antes != pedido.estado && _notificables.contains(pedido.estado)) {
        cambio = pedido;
      }
      _conocidos[pedido.id] = pedido.estado;
    }
    emit(
      state.copyWith(
        status: MisPedidosStatus.success,
        pedidosActivos: event.activos ? event.pedidos : null,
        pedidosHistorial: event.activos ? null : event.pedidos,
        cambio: cambio,
      ),
    );
  }

  /// Las listas que ya había se quedan y en [espera] se vuelve a suscribir.
  /// Al llegar datos, [_onUpdated] quita el aviso.
  void _onStreamFailed(MisPedidosStreamFailed event, Emitter<MisPedidosState> emit) {
    emit(state.copyWith(status: MisPedidosStatus.failure, errorMessage: event.message));
    _reconexion?.cancel();
    _reconexion = Timer(espera, () {
      if (!isClosed) add(MisPedidosStarted());
    });
  }

  @override
  Future<void> close() async {
    _reconexion?.cancel();
    await _subActivos?.cancel();
    await _subHistorial?.cancel();
    return super.close();
  }
}
