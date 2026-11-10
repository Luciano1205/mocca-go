import 'package:flutter/material.dart';

import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/pedido_secciones.dart';
import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/seguimiento/ui/screens/seguimiento_screen.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/domiciliario_card.dart';
import 'package:mocca_go/features/seguimiento/ui/widgets/linea_tiempo.dart';
import 'package:mocca_go/utils/formato.dart';

/// 11d · Pedido entregado y 11e · Pedido cancelado, desde el historial.
/// Ya no cambia, así que no necesita Bloc: muestra el [Pedido] que llega
/// por la ruta.
class DetalleMiPedidoScreen extends StatelessWidget {
  const DetalleMiPedidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pedido = ModalRoute.of(context)!.settings.arguments as Pedido;
    final entregado = pedido.estado == EstadoPedido.entregado;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            PedidoEncabezado(pedido: pedido, subtitulo: SeguimientoScreen.subtitulo(pedido)),
            const SizedBox(height: 20),
            if (entregado) ...[
              MessageBanner(
                title: 'Pedido entregado',
                subtitle: 'Pagaste ${formatoPesos(pedido.total)}. ¡Gracias por pedir!',
              ),
              const SizedBox(height: 14),
              LineaTiempo(pedido: pedido),
              const SizedBox(height: 14),
              DomiciliarioCard(pedido: pedido),
            ] else
              const MessageBanner(
                title: 'Pedido cancelado',
                subtitle: 'No se te cobró nada.',
                isError: true,
              ),
            const SizedBox(height: 14),
            EntregaCard(pedido: pedido),
            const SizedBox(height: 14),
            ProductosCard(pedido: pedido, etiquetaTotal: entregado ? 'Total pagado' : 'Total'),
          ],
        ),
      ),
    );
  }
}
