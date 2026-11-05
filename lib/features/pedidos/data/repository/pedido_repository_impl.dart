import 'package:mocca_go/features/pedidos/data/source/supabase_pedido_data_source.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';

/// Cumple [PedidoRepository] delegando en el data source de Supabase.
class PedidoRepositoryImpl implements PedidoRepository {
  final SupabasePedidoDataSource _dataSource;

  PedidoRepositoryImpl(this._dataSource);

  @override
  Future<Pedido> crear(NuevoPedido pedido) => _dataSource.crear(pedido);

  @override
  Future<List<Pedido>> misPedidos({required bool activos}) {
    return _dataSource.misPedidos(activos: activos);
  }

  @override
  Future<bool> cancelar(String pedidoId) => _dataSource.cancelar(pedidoId);

  @override
  Future<List<Pedido>> pendientes() => _dataSource.pendientes();

  @override
  Future<List<Pedido>> misEntregas({required bool activos}) {
    return _dataSource.misEntregas(activos: activos);
  }

  @override
  Future<bool> tomar(String pedidoId) => _dataSource.tomar(pedidoId);

  @override
  Future<bool> cambiarEstado(
    String pedidoId, {
    required EstadoPedido actual,
    required EstadoPedido nuevo,
  }) {
    return _dataSource.cambiarEstado(pedidoId, actual: actual, nuevo: nuevo);
  }

  @override
  Future<Pedido> getPedido(String pedidoId) => _dataSource.getPedido(pedidoId);
}
