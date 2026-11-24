import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_event.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_state.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/abrir_reclamo_usecase.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/get_motivos_reclamo_usecase.dart';

/// Bot del chat de reclamos, versión corta (21 a 21d · entregado, 22 y 22b ·
/// en curso). Hace las preguntas con respuestas predeterminadas, registra el
/// reclamo y cierra con "Registramos tu reclamo #R-102".
///
/// Recorrido: ¿Qué pasó? → ¿Qué producto? (si el motivo lo pide) →
/// ¿Cómo lo solucionamos? (si lo pide) → enviar.
class ReclamoBloc extends Bloc<ReclamoEvent, ReclamoState> {
  final GetMotivosReclamoUseCase _getMotivos;
  final AbrirReclamoUseCase _abrirReclamo;

  static const _preguntaProducto = '¿Qué producto? Puedes marcar varios.';
  static const _preguntaSolucion = '¿Cómo lo solucionamos?';

  ReclamoBloc(this._getMotivos, this._abrirReclamo, Pedido pedido)
    : super(ReclamoState(pedido: pedido)) {
    on<ReclamoStarted>(_onStarted);
    on<MotivoElegido>(_onMotivo);
    on<ProductosElegidos>(_onProductos);
    on<SolucionElegida>(_onSolucion);
    on<ReclamoReintentado>(_onReintentar);
  }

  Future<void> _onStarted(ReclamoStarted event, Emitter<ReclamoState> emit) async {
    emit(state.copyWith(paso: PasoReclamo.cargando));
    try {
      final motivos = await _getMotivos(state.pedido);
      emit(
        state.copyWith(motivos: motivos).conMensajes([
          MensajeChat.bot(
            'Hola, soy el asistente de Mocca Go! Veo que tienes una duda con tu '
            'pedido #${state.pedido.numero}.',
          ),
          const MensajeChat.bot('¿Qué pasó?'),
        ], paso: PasoReclamo.motivo),
      );
    } on Exception catch (e) {
      emit(state.conMensajes([MensajeChat.bot('$e')], paso: PasoReclamo.error));
    }
  }

  // Cada respuesta solo cuenta en su paso: un toque doble no manda dos
  // reclamos, porque el primero ya cambió el paso antes del segundo.

  Future<void> _onMotivo(MotivoElegido event, Emitter<ReclamoState> emit) async {
    if (state.paso != PasoReclamo.motivo) return;
    final motivo = event.motivo;
    final conRespuesta = state.copyWith(motivo: motivo);
    final respuesta = MensajeChat.cliente(motivo.texto);
    if (motivo.pideProducto) {
      emit(
        conRespuesta.conMensajes([
          respuesta,
          const MensajeChat.bot(_preguntaProducto),
        ], paso: PasoReclamo.producto),
      );
    } else if (motivo.pideSolucion) {
      emit(
        conRespuesta.conMensajes([
          respuesta,
          const MensajeChat.bot(_preguntaSolucion),
        ], paso: PasoReclamo.solucion),
      );
    } else {
      emit(conRespuesta.conMensajes([respuesta], paso: PasoReclamo.enviando));
      await _enviar(emit);
    }
  }

  Future<void> _onProductos(ProductosElegidos event, Emitter<ReclamoState> emit) async {
    if (state.paso != PasoReclamo.producto) return;
    final conRespuesta = state.copyWith(productos: event.productos);
    final respuesta = MensajeChat.cliente(event.productos.map((p) => p.nombre).join(', '));
    if (state.motivo!.pideSolucion) {
      emit(
        conRespuesta.conMensajes([
          respuesta,
          const MensajeChat.bot(_preguntaSolucion),
        ], paso: PasoReclamo.solucion),
      );
    } else {
      emit(conRespuesta.conMensajes([respuesta], paso: PasoReclamo.enviando));
      await _enviar(emit);
    }
  }

  Future<void> _onSolucion(SolucionElegida event, Emitter<ReclamoState> emit) async {
    if (state.paso != PasoReclamo.solucion) return;
    emit(
      state.copyWith(solucion: event.solucion).conMensajes([
        MensajeChat.cliente(event.solucion.etiqueta),
      ], paso: PasoReclamo.enviando),
    );
    await _enviar(emit);
  }

  /// Si nunca llegaron los motivos, vuelve a empezar; si no, reintenta el envío.
  Future<void> _onReintentar(ReclamoReintentado event, Emitter<ReclamoState> emit) async {
    if (state.paso != PasoReclamo.error) return;
    if (state.motivos.isEmpty) {
      emit(state.copyWith(mensajes: const []));
      await _onStarted(ReclamoStarted(), emit);
      return;
    }
    emit(state.copyWith(paso: PasoReclamo.enviando));
    await _enviar(emit);
  }

  Future<void> _enviar(Emitter<ReclamoState> emit) async {
    try {
      final reclamo = await _abrirReclamo(
        state.pedido,
        motivo: state.motivo!,
        productos: state.productos,
        solucion: state.solucion,
      );
      emit(
        state.copyWith(reclamo: reclamo).conMensajes([
          MensajeChat.bot(
            'Registramos tu reclamo #${reclamo.codigo}. '
            'Alguien del equipo te contactará pronto.',
          ),
        ], paso: PasoReclamo.listo),
      );
    } on Exception catch (e) {
      emit(state.conMensajes([MensajeChat.bot('$e')], paso: PasoReclamo.error));
    }
  }
}
