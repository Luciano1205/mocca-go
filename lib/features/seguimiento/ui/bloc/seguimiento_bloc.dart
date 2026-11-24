import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedido_usecase.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';
import 'package:mocca_go/utils/reconexion.dart';

/// Seguimiento de un pedido del cliente en tiempo real (11 / 11b), su
/// cancelación (11c) y la calificación del domiciliario al entregarlo (12).
///
/// Empieza con el [Pedido] que llega por la ruta. Solo el Bloc escucha el
/// Stream y lo cancela en [close].
class SeguimientoBloc extends Bloc<SeguimientoEvent, SeguimientoState> {
  final WatchPedidoUseCase _watchPedido;
  final CancelarPedidoUseCase _cancelar;
  final CalificarUseCase _calificar;
  final GetMiCalificacionUseCase _getMiCalificacion;

  /// Cuánto esperar para reconectar; solo cambia en las pruebas.
  final Duration espera;

  StreamSubscription<Pedido>? _subscription;

  /// Reconexión programada después de un error del Stream.
  Timer? _reconexion;

  /// El aviso a la vista es de conexión (se quita solo al llegar datos) y no
  /// de una acción como cancelar (ese se queda).
  bool _avisoDeConexion = false;

  SeguimientoBloc(
    this._watchPedido,
    this._cancelar,
    this._calificar,
    this._getMiCalificacion,
    Pedido pedido, {
    this.espera = esperaReconexion,
  }) : super(SeguimientoState(pedido: pedido)) {
    on<SeguimientoStarted>(_onStarted);
    on<SeguimientoUpdated>(_onUpdated);
    on<SeguimientoStreamFailed>(_onStreamFailed);
    on<CancelarPedidoConfirmed>(_onCancelar);
    on<CalificarDomiciliarioPressed>(_onCalificar);
  }

  Future<void> _onStarted(SeguimientoStarted event, Emitter<SeguimientoState> emit) async {
    _reconexion?.cancel();
    _avisoDeConexion = false;
    emit(state.copyWith(status: SeguimientoStatus.loading));
    // Si ya llega entregado (desde el historial), no se vuelve a pedir.
    if (state.pedido.estado == EstadoPedido.entregado) {
      emit(state.copyWith(miCalificacion: await _buscarMiCalificacion()));
    }
    // Sin await: cancel() corta los avisos de inmediato, y en las pruebas
    // de widgets (tiempo simulado) esperar su Future no termina nunca.
    _subscription?.cancel();
    _subscription = _watchPedido(state.pedido.id).listen(
      (pedido) => add(SeguimientoUpdated(pedido)),
      onError: (Object error) => add(SeguimientoStreamFailed(mensajeSinConexion)),
    );
  }

  Future<void> _onUpdated(SeguimientoUpdated event, Emitter<SeguimientoState> emit) async {
    final acabaDeEntregarse =
        state.pedido.estado != EstadoPedido.entregado &&
        event.pedido.estado == EstadoPedido.entregado;
    // El status de cancelar o calificar no se pisa con la actualización.
    final status =
        state.status == SeguimientoStatus.loading ||
            state.status == SeguimientoStatus.initial ||
            _avisoDeConexion
        ? SeguimientoStatus.success
        : state.status;
    _avisoDeConexion = false;
    // Si había un error a la vista (por ejemplo, no se pudo cancelar), sigue.
    final error = status == SeguimientoStatus.failure ? state.errorMessage : null;
    // Se emite el pedido antes de cualquier await: Supabase puede mandar el
    // mismo "Entregado" dos veces seguidas, y la segunda ya debe verlo
    // entregado para no abrir la hoja otra vez.
    emit(state.copyWith(status: status, pedido: event.pedido, errorMessage: error));
    if (!acabaDeEntregarse) return;

    final miCalificacion = state.miCalificacion ?? await _buscarMiCalificacion();
    emit(
      state.copyWith(
        errorMessage: error,
        miCalificacion: miCalificacion,
        pedirCalificacion: miCalificacion == null,
      ),
    );
  }

  /// El pedido que ya había se queda y en [espera] se vuelve a suscribir.
  void _onStreamFailed(SeguimientoStreamFailed event, Emitter<SeguimientoState> emit) {
    _avisoDeConexion = true;
    emit(state.copyWith(status: SeguimientoStatus.failure, errorMessage: event.message));
    _reconexion?.cancel();
    _reconexion = Timer(espera, () {
      if (!isClosed) add(SeguimientoStarted());
    });
  }

  Future<void> _onCancelar(CancelarPedidoConfirmed event, Emitter<SeguimientoState> emit) async {
    _avisoDeConexion = false;
    emit(state.copyWith(status: SeguimientoStatus.cancelando));
    try {
      // El Stream trae el estado nuevo; no hace falta recargar.
      final pedido = await _cancelar(state.pedido.id);
      emit(state.copyWith(status: SeguimientoStatus.cancelado, pedido: pedido));
    } on Exception catch (e) {
      emit(state.copyWith(status: SeguimientoStatus.failure, errorMessage: '$e'));
    }
  }

  Future<void> _onCalificar(
    CalificarDomiciliarioPressed event,
    Emitter<SeguimientoState> emit,
  ) async {
    _avisoDeConexion = false;
    emit(state.copyWith(status: SeguimientoStatus.calificando));
    try {
      await _calificar(state.pedido, valor: event.valor);
      emit(state.copyWith(status: SeguimientoStatus.success, miCalificacion: event.valor));
    } on Exception catch (e) {
      emit(state.copyWith(status: SeguimientoStatus.failure, errorMessage: '$e'));
    }
  }

  /// null si aún no calificó o si no se pudo saber (la base evita el duplicado).
  Future<int?> _buscarMiCalificacion() async {
    try {
      return await _getMiCalificacion(state.pedido.id);
    } on Exception {
      return null;
    }
  }

  @override
  Future<void> close() async {
    _reconexion?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
