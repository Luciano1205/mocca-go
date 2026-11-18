import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/calificaciones/domain/errors/calificacion_failure.dart';

/// Tabla `calificacion`. El trigger pone el autor, a quién se califica y
/// recalcula el promedio; la app solo manda el pedido y el valor.
class SupabaseCalificacionDataSource {
  final SupabaseClient _client;

  SupabaseCalificacionDataSource(this._client);

  Future<void> calificar(String pedidoId, {required int valor}) async {
    try {
      await _client.from('calificacion').insert({'pedido_id': pedidoId, 'valor': valor});
    } on PostgrestException catch (e) {
      // 23505: ya existe (pedido_id, autor_id). P0001: mensaje del trigger.
      if (e.code == '23505') {
        throw const CalificacionFailure('Ya calificaste este pedido.');
      }
      throw CalificacionFailure(
        e.code == 'P0001' ? e.message : 'No se pudo guardar tu calificación.',
      );
    }
  }

  Future<int?> miCalificacion(String pedidoId) async {
    try {
      final row = await _client
          .from('calificacion')
          .select('valor')
          .eq('pedido_id', pedidoId)
          .eq('autor_id', _client.auth.currentUser!.id)
          .maybeSingle();
      return row?['valor'] as int?;
    } on PostgrestException {
      throw const CalificacionFailure('No se pudo cargar la calificación.');
    }
  }
}
