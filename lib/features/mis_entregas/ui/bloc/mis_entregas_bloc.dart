import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_event.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_state.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_entregas_usecase.dart';

/// Carga las entregas del domiciliario (16 · Activos, 16b · Historial).
class MisEntregasBloc extends Bloc<MisEntregasEvent, MisEntregasState> {
  final GetMisEntregasUseCase _getMisEntregas;

  MisEntregasBloc(this._getMisEntregas) : super(const MisEntregasState()) {
    on<MisEntregasRequested>(_onRequested);
  }

  Future<void> _onRequested(
    MisEntregasRequested event,
    Emitter<MisEntregasState> emit,
  ) async {
    final activos = event.activos ?? state.activos;
    // Al cambiar de pestaña se limpia la lista para no mostrar la otra.
    emit(
      state.copyWith(
        status: MisEntregasStatus.loading,
        activos: activos,
        pedidos: activos == state.activos ? state.pedidos : const [],
      ),
    );
    try {
      final pedidos = await _getMisEntregas(activos: activos);
      emit(state.copyWith(status: MisEntregasStatus.success, pedidos: pedidos));
    } on Exception catch (e) {
      emit(state.copyWith(status: MisEntregasStatus.failure, errorMessage: '$e'));
    }
  }
}
