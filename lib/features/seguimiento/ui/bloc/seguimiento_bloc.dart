import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_pedido_usecase.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';

/// Seguimiento de un pedido del cliente (11) y su cancelación (11c).
/// Empieza con el [Pedido] que llega por la ruta y lo recarga con el
/// historial completo.
class SeguimientoBloc extends Bloc<SeguimientoEvent, SeguimientoState> {
  final GetPedidoUseCase _getPedido;
  final CancelarPedidoUseCase _cancelar;

  SeguimientoBloc(this._getPedido, this._cancelar, Pedido pedido)
    : super(SeguimientoState(pedido: pedido)) {
    on<SeguimientoRequested>(_onRequested);
    on<CancelarPedidoConfirmed>(_onCancelar);
  }

  Future<void> _onRequested(SeguimientoRequested event, Emitter<SeguimientoState> emit) async {
    emit(state.copyWith(status: SeguimientoStatus.loading));
    try {
      final pedido = await _getPedido(state.pedido.id);
      emit(state.copyWith(status: SeguimientoStatus.success, pedido: pedido));
    } on Exception catch (e) {
      emit(state.copyWith(status: SeguimientoStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> _onCancelar(CancelarPedidoConfirmed event, Emitter<SeguimientoState> emit) async {
    emit(state.copyWith(status: SeguimientoStatus.cancelando));
    try {
      final pedido = await _cancelar(state.pedido.id);
      emit(state.copyWith(status: SeguimientoStatus.cancelado, pedido: pedido));
    } on Exception catch (e) {
      // Si un domiciliario lo tomó, se recarga para mostrar quién.
      final pedido = await _recargar();
      emit(state.copyWith(status: SeguimientoStatus.failure, pedido: pedido, errorMessage: '$e'));
    }
  }

  Future<Pedido?> _recargar() async {
    try {
      return await _getPedido(state.pedido.id);
    } on Exception {
      return null;
    }
  }
}
