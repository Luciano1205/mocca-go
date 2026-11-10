import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/catalogo/domain/usecases/get_entidades_pago_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_zonas_usecase.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_event.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_state.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/crear_pedido_usecase.dart';

/// Carga zonas y entidades y envía el pedido (08 → 09 · Pedido enviado).
class DatosEntregaBloc extends Bloc<DatosEntregaEvent, DatosEntregaState> {
  final GetZonasUseCase _getZonas;
  final GetEntidadesPagoUseCase _getEntidades;
  final CrearPedidoUseCase _crearPedido;

  DatosEntregaBloc(this._getZonas, this._getEntidades, this._crearPedido)
    : super(const DatosEntregaState()) {
    on<DatosEntregaRequested>(_onRequested);
    on<DatosEntregaConfirmed>(_onConfirmed);
  }

  Future<void> _onRequested(DatosEntregaRequested event, Emitter<DatosEntregaState> emit) async {
    emit(state.copyWith(status: DatosEntregaStatus.loading));
    try {
      final zonas = await _getZonas();
      final entidades = await _getEntidades();
      emit(state.copyWith(status: DatosEntregaStatus.ready, zonas: zonas, entidades: entidades));
    } on Exception catch (e) {
      emit(state.copyWith(status: DatosEntregaStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> _onConfirmed(DatosEntregaConfirmed event, Emitter<DatosEntregaState> emit) async {
    emit(state.copyWith(status: DatosEntregaStatus.enviando));
    try {
      final pedido = await _crearPedido(event.pedido);
      emit(state.copyWith(status: DatosEntregaStatus.enviado, pedido: pedido));
    } on Exception catch (e) {
      emit(state.copyWith(status: DatosEntregaStatus.failure, errorMessage: '$e'));
    }
  }
}
