import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';

/// Lee la tabla `usuario`. RLS solo deja leer el perfil propio.
class SupabaseUsuarioDataSource {
  final SupabaseClient _client;

  SupabaseUsuarioDataSource(this._client);

  Future<Usuario> getUsuario(String id) async {
    try {
      final row = await _client
          .from('usuario')
          .select(
            'id, nombre, correo, rol, descripcion, '
            'calificacion_promedio, total_calificaciones',
          )
          .eq('id', id)
          .single();
      return Usuario(
        id: row['id'] as String,
        nombre: row['nombre'] as String,
        correo: row['correo'] as String,
        rol: Rol.values.byName(row['rol'] as String),
        descripcion: row['descripcion'] as String?,
        calificacionPromedio:
            (row['calificacion_promedio'] as num?)?.toDouble() ?? 0,
        totalCalificaciones: (row['total_calificaciones'] as int?) ?? 0,
      );
    } on PostgrestException {
      throw const AuthFailure('No se pudo cargar tu perfil.');
    }
  }
}
