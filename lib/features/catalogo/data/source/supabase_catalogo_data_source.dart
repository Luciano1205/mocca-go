import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/catalogo/domain/entities/categoria.dart';
import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/catalogo/domain/errors/catalogo_failure.dart';

/// Lee el catálogo. Las fotos están en el bucket público `productos`.
class SupabaseCatalogoDataSource {
  final SupabaseClient _client;

  SupabaseCatalogoDataSource(this._client);

  Future<List<Categoria>> getCategorias() async {
    try {
      final rows = await _client
          .from('categoria')
          .select('id, nombre')
          .order('orden', ascending: true);
      return rows
          .map((r) => Categoria(id: r['id'] as String, nombre: r['nombre'] as String))
          .toList();
    } on PostgrestException {
      throw const CatalogoFailure('No se pudo cargar el menú.');
    }
  }

  Future<List<Producto>> getProductos({String? categoriaId}) async {
    try {
      var query = _client.from('producto').select(
        'id, categoria_id, nombre, descripcion, precio, imagen_path, disponible',
      );
      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }
      final rows = await query.order('precio', ascending: true);
      return rows.map(_toProducto).toList();
    } on PostgrestException {
      throw const CatalogoFailure('No se pudo cargar el menú.');
    }
  }

  Future<List<Zona>> getZonas() async {
    try {
      final rows = await _client.from('zona').select('id, nombre').order('orden', ascending: true);
      return rows
          .map((r) => Zona(id: r['id'] as String, nombre: r['nombre'] as String))
          .toList();
    } on PostgrestException {
      throw const CatalogoFailure('No se pudieron cargar las zonas.');
    }
  }

  Future<List<EntidadPago>> getEntidadesPago() async {
    try {
      final rows = await _client
          .from('entidad_pago')
          .select('id, nombre, dato_destino, titular')
          .order('nombre', ascending: true);
      return rows
          .map(
            (r) => EntidadPago(
              id: r['id'] as String,
              nombre: r['nombre'] as String,
              datoDestino: r['dato_destino'] as String,
              titular: r['titular'] as String,
            ),
          )
          .toList();
    } on PostgrestException {
      throw const CatalogoFailure('No se pudieron cargar los medios de pago.');
    }
  }

  /// La RLS solo deja cambiarla a los domiciliarios; quién y cuándo lo
  /// pone un trigger.
  Future<void> cambiarDisponibilidad(String productoId, {required bool disponible}) async {
    try {
      final rows = await _client
          .from('producto')
          .update({'disponible': disponible})
          .eq('id', productoId)
          .select('id');
      if (rows.isEmpty) {
        throw const CatalogoFailure('No tienes permiso para cambiar este producto.');
      }
    } on PostgrestException {
      throw const CatalogoFailure('No se pudo actualizar el producto.');
    }
  }

  /// `producto` no necesita relaciones, así que las filas del stream ya
  /// sirven tal cual (lección "El Stream viaja por las capas").
  Stream<List<Producto>> watchProductos() {
    return _client
        .from('producto')
        .stream(primaryKey: ['id'])
        .order('precio', ascending: true)
        .map((rows) => rows.map(_toProducto).toList());
  }

  Producto _toProducto(Map<String, dynamic> row) {
    final path = row['imagen_path'] as String?;
    return Producto(
      id: row['id'] as String,
      categoriaId: row['categoria_id'] as String,
      nombre: row['nombre'] as String,
      descripcion: row['descripcion'] as String?,
      precio: row['precio'] as int,
      // getPublicUrl no va a la red: solo arma la URL.
      imagenUrl: path == null ? null : _client.storage.from('productos').getPublicUrl(path),
      disponible: row['disponible'] as bool,
    );
  }
}
