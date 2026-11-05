import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/pedidos/domain/usecases/get_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_event.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_state.dart';

/// Carga el feed del domiciliario (14 · Pedidos pendientes).
class PendientesBloc extends Bloc<PendientesEvent, PendientesState> {
  final GetPedidosPendientesUseCase _getPendientes;

  PendientesBloc(this._getPendientes) : super(const PendientesState()) {
    on<PendientesRequested>(_onRequested);
  }

  Future<void> _onRequested(
    PendientesRequested event,
    Emitter<PendientesState> emit,
  ) async {
    emit(state.copyWith(status: PendientesStatus.loading));
    try {
      final pedidos = await _getPendientes();
      emit(state.copyWith(status: PendientesStatus.success, pedidos: pedidos));
    } on Exception catch (e) {
      emit(state.copyWith(status: PendientesStatus.failure, errorMessage: '$e'));
    }
  }
}
