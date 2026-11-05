import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';

/// Lo que la app necesita del catálogo, sin decir quién lo cumple.
abstract class CatalogoRepository {
  /// Categorías en el orden del menú.
  Future<List<Categoria>> getCategorias();

  /// Productos del menú; con [categoriaId] solo los de esa categoría.
  Future<List<Producto>> getProductos({String? categoriaId});

  /// Zonas activas del campus.
  Future<List<Zona>> getZonas();

  /// Entidades activas para pagar por transferencia.
  Future<List<EntidadPago>> getEntidadesPago();
}
