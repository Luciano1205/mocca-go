import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';

/// Entidades para pagar por transferencia (08 · Datos de entrega).
class GetEntidadesPagoUseCase {
  final CatalogoRepository _catalogo;

  GetEntidadesPagoUseCase(this._catalogo);

  Future<List<EntidadPago>> call() => _catalogo.getEntidadesPago();
}
