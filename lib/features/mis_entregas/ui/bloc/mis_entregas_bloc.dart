import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_event.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_entregas_usecase.dart';

/// Entregas del domiciliario en tiempo real (16 · Activos, 16b · Historial).
/// Solo el Bloc escucha el Stream y lo cancela en [close].
class MisEntregasBloc extends Bloc<MisEntregasEvent, MisEntregasState> {
  final WatchMisEntregasUseCase _watchMisEntregas;

  StreamSubscription<List<Pedido>>? _subscription;

  MisEntregasBloc(this._watchMisEntregas) : super(const MisEntregasState()) {
    on<MisEntregasStarted>(_onStarted);
    on<MisEntregasUpdated>(_onUpdated);
    on<MisEntregasStreamFailed>(_onStreamFailed);
  }

  void _onStarted(MisEntregasStarted event, Emitter<MisEntregasState> emit) {
    final activos = event.activos ?? state.activos;
    // Al cambiar de pestaña se limpia la lista para no mostrar la otra.
    emit(
      state.copyWith(
        status: MisEntregasStatus.loading,
        activos: activos,
        pedidos: activos == state.activos ? state.pedidos : const [],
      ),
    );
    // Sin await: cancel() corta los avisos de inmediato, y en las pruebas
    // de widgets (tiempo simulado) esperar su Future no termina nunca.
    _subscription?.cancel();
    _subscription = _watchMisEntregas(activos: activos).listen(
      (pedidos) => add(MisEntregasUpdated(pedidos)),
      onError: (Object error) => add(MisEntregasStreamFailed('$error')),
    );
  }

  void _onUpdated(MisEntregasUpdated event, Emitter<MisEntregasState> emit) {
    emit(state.copyWith(status: MisEntregasStatus.success, pedidos: event.pedidos));
  }

  void _onStreamFailed(MisEntregasStreamFailed event, Emitter<MisEntregasState> emit) {
    emit(state.copyWith(status: MisEntregasStatus.failure, errorMessage: event.message));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
