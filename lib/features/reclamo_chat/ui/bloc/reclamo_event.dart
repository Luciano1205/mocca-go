import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';

/// Eventos del chat de reclamos (21 y 22).
abstract class ReclamoEvent {}

/// Al abrir el chat: el bot saluda y pregunta "¿Qué pasó?".
class ReclamoStarted extends ReclamoEvent {}

/// El cliente tocó un motivo.
class MotivoElegido extends ReclamoEvent {
  final MotivoReclamo motivo;

  MotivoElegido(this.motivo);
}

/// El cliente marcó los productos afectados y tocó "Continuar".
class ProductosElegidos extends ReclamoEvent {
  final List<ItemPedido> productos;

  ProductosElegidos(this.productos);
}

/// El cliente eligió cómo prefiere que se solucione.
class SolucionElegida extends ReclamoEvent {
  final SolucionReclamo solucion;

  SolucionElegida(this.solucion);
}

/// "Reintentar" después de un error: repite el paso que falló.
class ReclamoReintentado extends ReclamoEvent {}
