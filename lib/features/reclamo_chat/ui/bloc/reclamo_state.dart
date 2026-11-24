import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';

/// Una burbuja del chat: del bot a la izquierda, del cliente a la derecha.
class MensajeChat {
  final String texto;
  final bool delBot;

  const MensajeChat.bot(this.texto) : delBot = true;

  const MensajeChat.cliente(this.texto) : delBot = false;
}

/// Qué está esperando el bot. [error] deja reintentar.
enum PasoReclamo { cargando, motivo, producto, solucion, enviando, listo, error }

/// Estado del chat: la conversación, el paso actual y lo elegido hasta ahora.
class ReclamoState {
  final Pedido pedido;
  final PasoReclamo paso;
  final List<MensajeChat> mensajes;

  /// Opciones de la primera pregunta (según el pedido esté en curso o entregado).
  final List<MotivoReclamo> motivos;
  final MotivoReclamo? motivo;
  final List<ItemPedido> productos;
  final SolucionReclamo? solucion;

  /// El reclamo registrado, al final: "#R-102".
  final Reclamo? reclamo;

  const ReclamoState({
    required this.pedido,
    this.paso = PasoReclamo.cargando,
    this.mensajes = const [],
    this.motivos = const [],
    this.motivo,
    this.productos = const [],
    this.solucion,
    this.reclamo,
  });

  ReclamoState copyWith({
    PasoReclamo? paso,
    List<MensajeChat>? mensajes,
    List<MotivoReclamo>? motivos,
    MotivoReclamo? motivo,
    List<ItemPedido>? productos,
    SolucionReclamo? solucion,
    Reclamo? reclamo,
  }) {
    return ReclamoState(
      pedido: pedido,
      paso: paso ?? this.paso,
      mensajes: mensajes ?? this.mensajes,
      motivos: motivos ?? this.motivos,
      motivo: motivo ?? this.motivo,
      productos: productos ?? this.productos,
      solucion: solucion ?? this.solucion,
      reclamo: reclamo ?? this.reclamo,
    );
  }

  /// Agrega una o más burbujas a la conversación.
  ReclamoState conMensajes(List<MensajeChat> nuevos, {required PasoReclamo paso}) {
    return copyWith(paso: paso, mensajes: [...mensajes, ...nuevos]);
  }
}
