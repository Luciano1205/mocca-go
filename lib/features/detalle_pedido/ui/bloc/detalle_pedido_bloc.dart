import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_event.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/tomar_pedido_usecase.dart';

/// Detalle de un pendiente y el botón "Tomar pedido" (15 / 15b).
class DetallePedidoBloc extends Bloc<DetallePedidoEvent, DetallePedidoState> {
  final TomarPedidoUseCase _tomar;

  DetallePedidoBloc(this._tomar, Pedido pedido)
    : super(DetallePedidoState(pedido: pedido)) {
    on<TomarPedidoPressed>(_onTomar);
  }

  Future<void> _onTomar(
    TomarPedidoPressed event,
    Emitter<DetallePedidoState> emit,
  ) async {
    emit(state.copyWith(status: DetallePedidoStatus.tomando));
    try {
      final pedido = await _tomar(state.pedido.id);
      emit(state.copyWith(status: DetallePedidoStatus.tomado, pedido: pedido));
    } on PedidoYaTomadoFailure {
      emit(state.copyWith(status: DetallePedidoStatus.yaTomado));
    } on Exception catch (e) {
      emit(state.copyWith(status: DetallePedidoStatus.failure, errorMessage: '$e'));
    }
  }
}
