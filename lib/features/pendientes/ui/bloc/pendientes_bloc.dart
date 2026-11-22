import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_state.dart';

/// Feed del domiciliario en tiempo real (14 · Pedidos pendientes).
///
/// Como en "El Stream viaja por las capas": el Bloc es el único que escucha,
/// guarda la suscripción y la cancela en [close].
class PendientesBloc extends Bloc<PendientesEvent, PendientesState> {
  final WatchPedidosPendientesUseCase _watchPendientes;

  StreamSubscription<List<Pedido>>? _subscription;

  /// Ids que ya estaban en el feed. null hasta la primera emisión, para no
  /// notificar los pedidos que ya había al abrir la app.
  Set<String>? _conocidos;

  PendientesBloc(this._watchPendientes) : super(const PendientesState()) {
    on<PendientesStarted>(_onStarted);
    on<PendientesUpdated>(_onUpdated);
    on<PendientesStreamFailed>(_onStreamFailed);
  }

  Future<void> _onStarted(PendientesStarted event, Emitter<PendientesState> emit) async {
    emit(state.copyWith(status: PendientesStatus.loading));
    await _subscription?.cancel();
    _conocidos = null;
    _subscription = _watchPendientes().listen(
      (pedidos) => add(PendientesUpdated(pedidos)),
      onError: (Object error) => add(PendientesStreamFailed('$error')),
    );
  }

  void _onUpdated(PendientesUpdated event, Emitter<PendientesState> emit) {
    final conocidos = _conocidos;
    // El feed va del más antiguo al más reciente: el último nuevo es el que
    // acaba de llegar.
    final nuevos = conocidos == null
        ? const <Pedido>[]
        : event.pedidos.where((p) => !conocidos.contains(p.id)).toList();
    _conocidos = event.pedidos.map((p) => p.id).toSet();
    emit(
      state.copyWith(
        status: PendientesStatus.success,
        pedidos: event.pedidos,
        nuevo: nuevos.isEmpty ? null : nuevos.last,
      ),
    );
  }

  void _onStreamFailed(PendientesStreamFailed event, Emitter<PendientesState> emit) {
    emit(state.copyWith(status: PendientesStatus.failure, errorMessage: event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
