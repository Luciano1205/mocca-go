import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// Lo que la app necesita de los pedidos, sin decir quién lo cumple.
/// Siempre actúa como el usuario de la sesión.
abstract class PedidoRepository {
  // ---------- Cliente ----------

  /// Crea el pedido con sus líneas y su pago. Devuelve el pedido guardado.
  Future<Pedido> crear(NuevoPedido pedido);

  /// Mis pedidos: los activos o los terminados (entregados y cancelados).
  Future<List<Pedido>> misPedidos({required bool activos});

  /// Cancela un pedido propio. Devuelve false si ya no estaba pendiente.
  Future<bool> cancelar(String pedidoId);

  // ---------- Domiciliario ----------

  /// Pedidos que nadie ha tomado, del más antiguo al más reciente.
  Future<List<Pedido>> pendientes();

  /// Mis entregas: las activas o las terminadas.
  Future<List<Pedido>> misEntregas({required bool activos});

  /// Toma un pendiente. Devuelve false si otro domiciliario lo tomó primero.
  Future<bool> tomar(String pedidoId);

  /// Pasa el pedido de [actual] a [nuevo]. Devuelve false si ya no estaba
  /// en [actual].
  Future<bool> cambiarEstado(
    String pedidoId, {
    required EstadoPedido actual,
    required EstadoPedido nuevo,
  });

  // ---------- Ambos ----------

  /// Un pedido con todo su detalle.
  Future<Pedido> getPedido(String pedidoId);
}
