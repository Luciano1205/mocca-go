import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/errors/pedido_failure.dart';

/// Las consultas a `pedido` y sus tablas relacionadas.
///
/// La RLS decide qué ve cada quien: el cliente sus pedidos y el domiciliario
/// los pendientes y los que tomó. Los totales, el cambio y el historial los
/// calculan los triggers de la base de datos.
class SupabasePedidoDataSource {
  final SupabaseClient _client;

  SupabasePedidoDataSource(this._client);

  // `pedido` tiene dos llaves hacia `usuario`: el `!` dice por cuál ir
  // (sin él Supabase responde PGRST201, igual que en el Laboratorio 6).
  static const _columns = 'id, numero, estado, referencia, nota, '
      'subtotal, costo_domicilio, total, creado_en, '
      'cliente:usuario!cliente_id(nombre), '
      'domiciliario:usuario!domiciliario_id(nombre, calificacion_promedio), '
      'zona(nombre), '
      'detalle_pedido(nombre_producto, precio_unitario, cantidad, subtotal), '
      'pago(metodo, valor_entregado, cambio, '
      'entidad:entidad_pago(nombre, dato_destino, titular)), '
      'historial_estado(estado, fecha)';

  static final _activos = [
    EstadoPedido.pendiente.valor,
    EstadoPedido.aceptado.valor,
    EstadoPedido.enCamino.valor,
  ];
  static final _terminados = [
    EstadoPedido.entregado.valor,
    EstadoPedido.cancelado.valor,
  ];

  String get _uid => _client.auth.currentUser!.id;

  // ---------- Cliente ----------

  Future<Pedido> crear(NuevoPedido nuevo) async {
    final pedidoId = await _insertarPedido(nuevo);

    try {
      // Una sola petición para todas las líneas (insert en lote).
      await _client.from('detalle_pedido').insert([
        for (final linea in nuevo.lineas)
          {
            'pedido_id': pedidoId,
            'producto_id': linea.productoId,
            'cantidad': linea.cantidad,
          },
      ]);
      await _client.from('pago').insert({
        'pedido_id': pedidoId,
        'metodo': nuevo.metodo.name,
        'valor_entregado': nuevo.valorEntregado,
        'entidad_pago_id': nuevo.entidadPagoId,
      });
    } on PostgrestException catch (e) {
      // El pedido quedó a medias: se borra para que no aparezca en el feed.
      try {
        await _client.from('pedido').delete().eq('id', pedidoId);
      } on PostgrestException {
        // El error que importa es el original.
      }
      throw PedidoFailure(_mensaje(e, 'No se pudo enviar tu pedido.'));
    }

    return getPedido(pedidoId);
  }

  Future<List<Pedido>> misPedidos({required bool activos}) {
    return _lista(
      _client
          .from('pedido')
          .select(_columns)
          .eq('cliente_id', _uid)
          .inFilter('estado', activos ? _activos : _terminados)
          .order('creado_en', ascending: false),
    );
  }

  Future<bool> cancelar(String pedidoId) {
    return _actualizar(
      _client
          .from('pedido')
          .update({'estado': EstadoPedido.cancelado.valor})
          .eq('id', pedidoId)
          .eq('estado', EstadoPedido.pendiente.valor)
          .select('id'),
      'No se pudo cancelar el pedido.',
    );
  }

  // ---------- Domiciliario ----------

  /// `pago!inner` deja fuera los pedidos que aún no terminan de guardarse
  /// (sin pago todavía), para que nadie tome uno a medias.
  Future<List<Pedido>> pendientes() {
    return _lista(
      _client
          .from('pedido')
          .select(_columns.replaceFirst('pago(', 'pago!inner('))
          .eq('estado', EstadoPedido.pendiente.valor)
          .order('creado_en'),
    );
  }

  Future<List<Pedido>> misEntregas({required bool activos}) {
    return _lista(
      _client
          .from('pedido')
          .select(_columns)
          .eq('domiciliario_id', _uid)
          .inFilter('estado', activos ? _activos : _terminados)
          .order('creado_en', ascending: false),
    );
  }

  /// El filtro por `estado = pendiente` es lo que evita que dos lo tomen:
  /// Postgres bloquea la fila, y el segundo ya no la encuentra pendiente.
  Future<bool> tomar(String pedidoId) {
    return _actualizar(
      _client
          .from('pedido')
          .update({
            'estado': EstadoPedido.aceptado.valor,
            'domiciliario_id': _uid,
          })
          .eq('id', pedidoId)
          .eq('estado', EstadoPedido.pendiente.valor)
          .select('id'),
      'No se pudo tomar el pedido.',
    );
  }

  Future<bool> cambiarEstado(
    String pedidoId, {
    required EstadoPedido actual,
    required EstadoPedido nuevo,
  }) {
    return _actualizar(
      _client
          .from('pedido')
          .update({'estado': nuevo.valor})
          .eq('id', pedidoId)
          .eq('domiciliario_id', _uid)
          .eq('estado', actual.valor)
          .select('id'),
      'No se pudo actualizar el pedido.',
    );
  }

  // ---------- Ambos ----------

  Future<Pedido> getPedido(String pedidoId) async {
    try {
      final row = await _client
          .from('pedido')
          .select(_columns)
          .eq('id', pedidoId)
          .single();
      return _toPedido(row);
    } on PostgrestException {
      throw const PedidoFailure('No se pudo cargar el pedido.');
    }
  }

  // ---------- Ayudas ----------

  Future<String> _insertarPedido(NuevoPedido nuevo) async {
    try {
      final row = await _client
          .from('pedido')
          .insert({
            'cliente_id': _uid,
            'zona_id': nuevo.zonaId,
            'referencia': nuevo.referencia,
            'nota': nuevo.nota,
          })
          .select('id')
          .single();
      return row['id'] as String;
    } on PostgrestException catch (e) {
      throw PedidoFailure(_mensaje(e, 'No se pudo enviar tu pedido.'));
    }
  }

  Future<List<Pedido>> _lista(Future<List<Map<String, dynamic>>> consulta) async {
    try {
      final rows = await consulta;
      return rows.map(_toPedido).toList();
    } on PostgrestException {
      throw const PedidoFailure('No se pudieron cargar los pedidos.');
    }
  }

  /// `update(...).select()` devuelve las filas que cambió: vacío significa
  /// que el filtro ya no encontró el pedido en el estado esperado.
  Future<bool> _actualizar(
    Future<List<Map<String, dynamic>>> consulta,
    String error,
  ) async {
    try {
      final rows = await consulta;
      return rows.isNotEmpty;
    } on PostgrestException catch (e) {
      throw PedidoFailure(_mensaje(e, error));
    }
  }

  /// Los errores de los triggers (código P0001) ya vienen en español.
  String _mensaje(PostgrestException e, String porDefecto) {
    return e.code == 'P0001' ? e.message : porDefecto;
  }

  Pedido _toPedido(Map<String, dynamic> row) {
    final cliente = row['cliente'] as Map<String, dynamic>?;
    final domiciliario = row['domiciliario'] as Map<String, dynamic>?;
    final zona = row['zona'] as Map<String, dynamic>?;
    final detalles = (row['detalle_pedido'] as List?) ?? const [];
    final historial = (row['historial_estado'] as List?) ?? const [];

    return Pedido(
      id: row['id'] as String,
      numero: row['numero'] as int,
      estado: EstadoPedido.desde(row['estado'] as String),
      clienteNombre: (cliente?['nombre'] as String?) ?? '',
      domiciliarioNombre: domiciliario?['nombre'] as String?,
      domiciliarioCalificacion:
          (domiciliario?['calificacion_promedio'] as num?)?.toDouble(),
      zona: (zona?['nombre'] as String?) ?? '',
      referencia: row['referencia'] as String,
      nota: row['nota'] as String?,
      items: [
        for (final d in detalles.cast<Map<String, dynamic>>())
          ItemPedido(
            nombre: d['nombre_producto'] as String,
            precioUnitario: d['precio_unitario'] as int,
            cantidad: d['cantidad'] as int,
            subtotal: d['subtotal'] as int,
          ),
      ],
      pago: _toPago(row['pago']),
      subtotal: row['subtotal'] as int,
      costoDomicilio: row['costo_domicilio'] as int,
      total: row['total'] as int,
      creadoEn: DateTime.parse(row['creado_en'] as String).toLocal(),
      historial: {
        for (final h in historial.cast<Map<String, dynamic>>())
          EstadoPedido.desde(h['estado'] as String):
              DateTime.parse(h['fecha'] as String).toLocal(),
      },
    );
  }

  /// `pago.pedido_id` es única, así que Supabase lo trae como un solo mapa;
  /// por si acaso también se acepta una lista.
  PagoPedido? _toPago(Object? valor) {
    final Map<String, dynamic>? pago = switch (valor) {
      Map<String, dynamic> m => m,
      List l when l.isNotEmpty => l.first as Map<String, dynamic>,
      _ => null,
    };
    if (pago == null) return null;
    final entidad = pago['entidad'] as Map<String, dynamic>?;
    return PagoPedido(
      metodo: MetodoPago.values.byName(pago['metodo'] as String),
      valorEntregado: pago['valor_entregado'] as int?,
      cambio: (pago['cambio'] as int?) ?? 0,
      entidadNombre: entidad?['nombre'] as String?,
      entidadDato: entidad?['dato_destino'] as String?,
      entidadTitular: entidad?['titular'] as String?,
    );
  }
}
