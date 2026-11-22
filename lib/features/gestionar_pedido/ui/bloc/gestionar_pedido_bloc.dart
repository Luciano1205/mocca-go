import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_event.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_state.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';

/// Pedido que el domiciliario está entregando (17 / 17b / 17c) y la
/// calificación del cliente al entregarlo (18).
class GestionarPedidoBloc extends Bloc<GestionarPedidoEvent, GestionarPedidoState> {
  final AvanzarPedidoUseCase _avanzar;
  final CalificarUseCase _calificar;
  final GetMiCalificacionUseCase _getMiCalificacion;

  GestionarPedidoBloc(
    this._avanzar,
    this._calificar,
    this._getMiCalificacion,
    Pedido pedido,
  ) : super(GestionarPedidoState(pedido: pedido)) {
    on<GestionarPedidoStarted>(_onStarted);
    on<AvanzarPedidoPressed>(_onAvanzar);
    on<CalificarClientePressed>(_onCalificar);
  }

  Future<void> _onStarted(
    GestionarPedidoStarted event,
    Emitter<GestionarPedidoState> emit,
  ) async {
    if (state.pedido.estado != EstadoPedido.entregado) return;
    try {
      final valor = await _getMiCalificacion(state.pedido.id);
      emit(state.copyWith(miCalificacion: valor));
    } on Exception {
      // Si no se pudo saber, se ofrece calificar; la base evita el duplicado.
    }
  }

  Future<void> _onAvanzar(
    AvanzarPedidoPressed event,
    Emitter<GestionarPedidoState> emit,
  ) async {
    emit(state.copyWith(status: GestionarPedidoStatus.avanzando));
    try {
      final pedido = await _avanzar(state.pedido);
      emit(
        state.copyWith(
          status: GestionarPedidoStatus.initial,
          pedido: pedido,
          pedirCalificacion: pedido.estado == EstadoPedido.entregado,
        ),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: GestionarPedidoStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> _onCalificar(
    CalificarClientePressed event,
    Emitter<GestionarPedidoState> emit,
  ) async {
    emit(state.copyWith(status: GestionarPedidoStatus.calificando));
    try {
      await _calificar(state.pedido, valor: event.valor);
      emit(
        state.copyWith(status: GestionarPedidoStatus.initial, miCalificacion: event.valor),
      );
    } on Exception catch (e) {
      emit(state.copyWith(status: GestionarPedidoStatus.failure, errorMessage: '$e'));
    }
  }
}
