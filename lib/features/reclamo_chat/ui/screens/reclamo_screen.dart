import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_bloc.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_event.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_state.dart';
import 'package:mocca_go/features/reclamo_chat/ui/widgets/burbuja.dart';
import 'package:mocca_go/features/reclamo_chat/ui/widgets/opcion_chat.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 21 a 21d (pedido entregado) y 22 / 22b (en curso) · Chat de reclamos.
/// Arriba la conversación y abajo las respuestas del paso actual.
class ReclamoScreen extends StatelessWidget {
  const ReclamoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReclamoBloc, ReclamoState>(
      builder: (context, state) {
        // Al revés para que la lista quede pegada abajo, como un chat.
        final mensajes = state.mensajes.reversed.toList();
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text('Ayuda con tu pedido'),
                Text(
                  'Pedido #${state.pedido.numero}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: mensajes.length,
                    itemBuilder: (_, i) => Burbuja(mensaje: mensajes[i]),
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: _Respuestas(state: state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Lo que el cliente puede responder en cada paso.
class _Respuestas extends StatelessWidget {
  final ReclamoState state;

  const _Respuestas({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReclamoBloc>();
    switch (state.paso) {
      case PasoReclamo.cargando:
      case PasoReclamo.enviando:
        return const _Escribiendo();
      case PasoReclamo.motivo:
        return _Opciones(
          children: [
            for (final m in state.motivos)
              OpcionChat(texto: m.texto, onTap: () => bloc.add(MotivoElegido(m))),
          ],
        );
      case PasoReclamo.producto:
        return _ElegirProductos(items: state.pedido.items);
      case PasoReclamo.solucion:
        return _Opciones(
          children: [
            for (final s in SolucionReclamo.values)
              OpcionChat(texto: s.etiqueta, onTap: () => bloc.add(SolucionElegida(s))),
          ],
        );
      case PasoReclamo.listo:
        return PrimaryButton(label: 'Volver al pedido', onPressed: () => Navigator.pop(context));
      case PasoReclamo.error:
        // Si el error no se arregla reintentando (por ejemplo, ya hay un
        // reclamo de ese pedido), también se puede salir.
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(label: 'Reintentar', onPressed: () => bloc.add(ReclamoReintentado())),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Volver al pedido',
              isSecondary: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
    }
  }
}

class _Opciones extends StatelessWidget {
  final List<Widget> children;

  const _Opciones({required this.children});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: children),
    );
  }
}

/// 21b · "¿Qué producto?": se pueden marcar varios y luego "Continuar".
class _ElegirProductos extends StatefulWidget {
  final List<ItemPedido> items;

  const _ElegirProductos({required this.items});

  @override
  State<_ElegirProductos> createState() => _ElegirProductosState();
}

class _ElegirProductosState extends State<_ElegirProductos> {
  final Set<ItemPedido> _elegidos = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Opciones(
          children: [
            for (final item in widget.items)
              OpcionChat(
                texto: '${item.cantidad} × ${item.nombre}',
                elegida: _elegidos.contains(item),
                onTap: () => setState(() {
                  if (!_elegidos.remove(item)) _elegidos.add(item);
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Continuar',
          // Sin productos marcados no hace nada.
          onPressed: () {
            if (_elegidos.isEmpty) return;
            final elegidos = widget.items.where(_elegidos.contains).toList();
            context.read<ReclamoBloc>().add(ProductosElegidos(elegidos));
          },
        ),
      ],
    );
  }
}

/// Mientras el bot "escribe". Sin animación para no trabar las pruebas.
class _Escribiendo extends StatelessWidget {
  const _Escribiendo();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.more_horiz, color: AppColors.textMuted),
          SizedBox(width: 8),
          Text(
            'El asistente está escribiendo…',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
