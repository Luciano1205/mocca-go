import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/reclamos/domain/entities/motivo_reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/errors/reclamo_failure.dart';

/// Tablas `motivo_reclamo`, `reclamo` y `reclamo_detalle`. Los triggers
/// revisan que el motivo corresponda al estado del pedido y que los
/// productos sean de ese pedido.
class SupabaseReclamoDataSource {
  final SupabaseClient _client;

  SupabaseReclamoDataSource(this._client);

  Future<List<MotivoReclamo>> getMotivos({required bool paraEntregado}) async {
    try {
      final rows = await _client
          .from('motivo_reclamo')
          .select('id, texto, aplica_a, pide_producto, pide_solucion')
          .eq('aplica_a', paraEntregado ? 'entregado' : 'en_curso')
          .order('orden', ascending: true);
      return rows
          .map(
            (r) => MotivoReclamo(
              id: r['id'] as String,
              texto: r['texto'] as String,
              paraEntregado: r['aplica_a'] == 'entregado',
              pideProducto: r['pide_producto'] as bool,
              pideSolucion: r['pide_solucion'] as bool,
            ),
          )
          .toList();
    } on PostgrestException {
      throw const ReclamoFailure('No se pudieron cargar las opciones.');
    }
  }

  Future<Reclamo> abrir(NuevoReclamo nuevo) async {
    try {
      final row = await _client
          .from('reclamo')
          .insert({
            'pedido_id': nuevo.pedidoId,
            'motivo_id': nuevo.motivoId,
            'solucion': nuevo.solucion?.valor,
          })
          .select('id, numero')
          .single();
      final reclamo = Reclamo(id: row['id'] as String, numero: row['numero'] as int);

      if (nuevo.detalleIds.isNotEmpty) {
        await _client.from('reclamo_detalle').insert([
          for (final detalleId in nuevo.detalleIds)
            {'reclamo_id': reclamo.id, 'detalle_pedido_id': detalleId},
        ]);
      }
      return reclamo;
    } on PostgrestException catch (e) {
      throw ReclamoFailure(
        e.code == 'P0001' ? e.message : 'No se pudo registrar tu reclamo.',
      );
    }
  }
}
