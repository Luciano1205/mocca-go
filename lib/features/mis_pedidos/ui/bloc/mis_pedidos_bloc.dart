import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_event.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_state.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_pedidos_usecase.dart';

/// Carga los pedidos del cliente (10 · Activos, 10b · Historial).
class MisPedidosBloc extends Bloc<MisPedidosEvent, MisPedidosState> {
  final GetMisPedidosUseCase _getMisPedidos;

  MisPedidosBloc(this._getMisPedidos) : super(const MisPedidosState()) {
    on<MisPedidosRequested>(_onRequested);
  }

  Future<void> _onRequested(MisPedidosRequested event, Emitter<MisPedidosState> emit) async {
    final activos = event.activos ?? state.activos;
    // Al cambiar de pestaña se limpia la lista para no mostrar la otra.
    emit(
      state.copyWith(
        status: MisPedidosStatus.loading,
        activos: activos,
        pedidos: activos == state.activos ? state.pedidos : const [],
      ),
    );
    try {
      // El más reciente arriba.
      final pedidos = [...await _getMisPedidos(activos: activos)]
        ..sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
      emit(state.copyWith(status: MisPedidosStatus.success, pedidos: pedidos));
    } on Exception catch (e) {
      emit(state.copyWith(status: MisPedidosStatus.failure, errorMessage: '$e'));
    }
  }
}
