import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/calificar_sheet.dart';
import 'package:mocca_go/components/estrellas.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_state.dart';
import 'package:mocca_go/theme/app_theme.dart';

/// 12 · Calificar domiciliario, ya entregado el pedido. Si ya calificó,
/// muestra sus estrellas; si tocó "Ahora no", deja el botón para hacerlo.
class CalificacionDomiciliario extends StatelessWidget {
  final SeguimientoState state;

  const CalificacionDomiciliario({super.key, required this.state});

  /// Abre la hoja "¡Tu pedido llegó!" y manda las estrellas al Bloc.
  static Future<void> calificar(BuildContext context, Pedido pedido) async {
    final bloc = context.read<SeguimientoBloc>();
    final nombre = (pedido.domiciliarioNombre ?? '').split(' ').first;
    final valor = await CalificarSheet.mostrar(
      context,
      titulo: '¡Tu pedido llegó!',
      pregunta: '¿Cómo te atendió $nombre?',
      nombre: pedido.domiciliarioNombre ?? '',
    );
    if (valor != null) bloc.add(CalificarDomiciliarioPressed(valor));
  }

  @override
  Widget build(BuildContext context) {
    final pedido = state.pedido;
    final nombre = (pedido.domiciliarioNombre ?? '').split(' ').first;
    final valor = state.miCalificacion;
    if (valor == null) {
      return PrimaryButton(
        label: 'Calificar a $nombre',
        isLoading: state.status == SeguimientoStatus.calificando,
        onPressed: () => calificar(context, pedido),
      );
    }
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Calificaste a $nombre',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          Estrellas(valor: valor, size: 20),
        ],
      ),
    );
  }
}
