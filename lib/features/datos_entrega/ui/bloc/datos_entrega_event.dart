import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';

/// Eventos de 08 · Datos de entrega.
abstract class DatosEntregaEvent {}

/// Cargar zonas y entidades de pago al abrir la pantalla.
class DatosEntregaRequested extends DatosEntregaEvent {}

/// El cliente tocó "Confirmar pedido" con el formulario ya validado.
class DatosEntregaConfirmed extends DatosEntregaEvent {
  final NuevoPedido pedido;

  DatosEntregaConfirmed(this.pedido);
}
