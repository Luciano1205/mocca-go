import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_event.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';

/// Pedido que el domiciliario está entregando (17 / 17b / 17c).
class GestionarPedidoBloc extends Bloc<GestionarPedidoEvent, GestionarPedidoState> {
  final AvanzarPedidoUseCase _avanzar;

  GestionarPedidoBloc(this._avanzar, Pedido pedido)
    : super(GestionarPedidoState(pedido: pedido)) {
    on<AvanzarPedidoPressed>(_onAvanzar);
  }

  Future<void> _onAvanzar(
    AvanzarPedidoPressed event,
    Emitter<GestionarPedidoState> emit,
  ) async {
    emit(state.copyWith(status: GestionarPedidoStatus.avanzando));
    try {
      final pedido = await _avanzar(state.pedido);
      emit(state.copyWith(status: GestionarPedidoStatus.initial, pedido: pedido));
    } on Exception catch (e) {
      emit(state.copyWith(status: GestionarPedidoStatus.failure, errorMessage: '$e'));
    }
  }
}
