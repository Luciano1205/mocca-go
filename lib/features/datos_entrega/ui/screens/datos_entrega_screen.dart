import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/info_row.dart';
import 'package:mocca_go/components/message_banner.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/components/surface_card.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_bloc.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_event.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_state.dart';
import 'package:mocca_go/features/datos_entrega/ui/widgets/opcion_card.dart';
import 'package:mocca_go/features/pedidos/domain/entities/nuevo_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';
import 'package:mocca_go/utils/formato.dart';

/// Billetes del prototipo para pagar en efectivo (08c).
const billetes = [20000, 50000, 100000];

/// Con qué paga en efectivo: el valor exacto, un billete o otro valor.
enum _Efectivo { exacto, billete, otro }

/// 08 · Datos de entrega: zona (08b), referencia, nota y pago en efectivo
/// (08c) o por transferencia (08d). Al confirmar va a 09 · Pedido enviado.
class DatosEntregaScreen extends StatefulWidget {
  const DatosEntregaScreen({super.key});

  @override
  State<DatosEntregaScreen> createState() => _DatosEntregaScreenState();
}

class _DatosEntregaScreenState extends State<DatosEntregaScreen> {
  final _referenciaController = TextEditingController();
  final _notaController = TextEditingController();
  final _otroController = TextEditingController();

  Zona? _zona;
  MetodoPago _metodo = MetodoPago.efectivo;
  _Efectivo _efectivo = _Efectivo.exacto;
  int? _billete;
  EntidadPago? _entidad;

  /// Errores de validación del formulario. Los de Supabase llegan en el
  /// estado del Bloc.
  String? _zonaError;
  String? _referenciaError;
  String? _otroError;
  String? _entidadError;

  @override
  void dispose() {
    _referenciaController.dispose();
    _notaController.dispose();
    _otroController.dispose();
    super.dispose();
  }

  int get _total => context.read<CarritoBloc>().state.total;

  /// Valor con el que paga en efectivo; null si es exacto o si "otro" no es un número.
  int? get _valorEntregado {
    switch (_efectivo) {
      case _Efectivo.exacto:
        return null;
      case _Efectivo.billete:
        return _billete;
      case _Efectivo.otro:
        return int.tryParse(_otroController.text.replaceAll('.', '').trim());
    }
  }

  /// 08b · Seleccionar zona, en una hoja que sube desde abajo.
  Future<void> _elegirZona(List<Zona> zonas) async {
    final zona = await showModalBottomSheet<Zona>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          children: [
            Text('¿Dónde te entregamos?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final z in zonas)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OpcionCard(
                  titulo: z.nombre,
                  icono: Icons.location_on_outlined,
                  elegida: z.id == _zona?.id,
                  onTap: () => Navigator.pop(context, z),
                ),
              ),
          ],
        ),
      ),
    );
    if (zona != null) {
      setState(() {
        _zona = zona;
        _zonaError = null;
      });
    }
  }

  void _confirmar() {
    final total = _total;
    final referencia = _referenciaController.text.trim();
    final valor = _valorEntregado;
    setState(() {
      _zonaError = _zona == null ? 'Elige la zona de entrega' : null;
      _referenciaError = referencia.isEmpty ? 'Escribe una referencia para encontrarte' : null;
      _otroError = null;
      _entidadError = null;
      if (_metodo == MetodoPago.efectivo && _efectivo == _Efectivo.otro) {
        if (valor == null) {
          _otroError = 'Escribe el valor con el que pagas';
        } else if (valor < total) {
          _otroError = 'Debe ser de al menos ${formatoPesos(total)}';
        }
      }
      if (_metodo == MetodoPago.transferencia && _entidad == null) {
        _entidadError = 'Elige a qué cuenta vas a transferir';
      }
    });
    if (_zonaError != null ||
        _referenciaError != null ||
        _otroError != null ||
        _entidadError != null) {
      return;
    }
    FocusScope.of(context).unfocus();
    final nota = _notaController.text.trim();
    context.read<DatosEntregaBloc>().add(
      DatosEntregaConfirmed(
        NuevoPedido(
          lineas: context.read<CarritoBloc>().state.lineas,
          zonaId: _zona!.id,
          referencia: referencia,
          nota: nota.isEmpty ? null : nota,
          metodo: _metodo,
          valorEntregado: _metodo == MetodoPago.efectivo ? valor : null,
          entidadPagoId: _metodo == MetodoPago.transferencia ? _entidad!.id : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.read<CarritoBloc>().state;
    return BlocConsumer<DatosEntregaBloc, DatosEntregaState>(
      listener: (context, state) {
        if (state.status == DatosEntregaStatus.enviado) {
          // Se vacía antes de navegar: después esta pantalla ya no existe.
          context.read<CarritoBloc>().add(CarritoVaciado());
          // Deja solo el panel debajo: al volver de 09 se llega al menú.
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.pedidoEnviado,
            ModalRoute.withName(AppRoutes.panelCliente),
            arguments: state.pedido,
          );
        }
      },
      builder: (context, state) {
        final enviando =
            state.status == DatosEntregaStatus.enviando ||
            state.status == DatosEntregaStatus.enviado;
        final sinDatos = state.zonas.isEmpty;
        return Scaffold(
          appBar: AppBar(title: const Text('Datos de entrega')),
          body: SafeArea(
            child: sinDatos
                ? _Cargando(state: state)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    children: [
                      if (state.status == DatosEntregaStatus.failure) ...[
                        MessageBanner(title: state.errorMessage!, isError: true),
                        const SizedBox(height: 16),
                      ],
                      SurfaceCard(
                        child: Column(
                          children: [
                            InfoRow(
                              label: carrito.totalUnidades == 1
                                  ? '1 producto'
                                  : '${carrito.totalUnidades} productos',
                              value: formatoPesos(carrito.total),
                            ),
                            const InfoRow(
                              label: 'Domicilio',
                              value: 'Gratis',
                              valueColor: AppColors.success,
                            ),
                            const SizedBox(height: 4),
                            InfoRow(
                              label: 'Total',
                              value: formatoPesos(carrito.total),
                              destacado: true,
                              valueColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const _Seccion('¿Dónde te entregamos?'),
                      OpcionCard(
                        titulo: _zona?.nombre ?? 'Elige la zona',
                        subtitulo: _zona == null ? 'Edificio o lugar del campus' : null,
                        icono: Icons.location_on_outlined,
                        elegida: _zona != null,
                        trailing: const Icon(Icons.expand_more, color: AppColors.textMuted),
                        onTap: () => _elegirZona(state.zonas),
                      ),
                      if (_zonaError != null) _ErrorTexto(_zonaError!),
                      const SizedBox(height: 16),
                      AppInput(
                        label: 'Referencia',
                        hint: 'Ej: piso 2, junto a la ventana',
                        controller: _referenciaController,
                        errorText: _referenciaError,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        label: 'Nota para el domiciliario (opcional)',
                        hint: 'Ej: llámame al llegar',
                        controller: _notaController,
                      ),
                      const _Seccion('¿Cómo vas a pagar?'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetodoChip(
                            texto: 'Efectivo',
                            activo: _metodo == MetodoPago.efectivo,
                            onTap: () => setState(() => _metodo = MetodoPago.efectivo),
                          ),
                          _MetodoChip(
                            texto: 'Transferencia',
                            activo: _metodo == MetodoPago.transferencia,
                            onTap: () => setState(() => _metodo = MetodoPago.transferencia),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (_metodo == MetodoPago.efectivo)
                        ..._opcionesEfectivo(carrito.total)
                      else
                        ..._opcionesTransferencia(state.entidades, carrito.total),
                    ],
                  ),
          ),
          bottomNavigationBar: sinDatos
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                    child: PrimaryButton(
                      label: 'Confirmar pedido · ${formatoPesos(carrito.total)}',
                      isLoading: enviando,
                      onPressed: _confirmar,
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// 08c · Efectivo: exacto, billetes u otro valor, con el cambio.
  List<Widget> _opcionesEfectivo(int total) {
    final valor = _valorEntregado;
    final cambio = (valor != null && valor >= total) ? valor - total : null;
    return [
      OpcionCard(
        titulo: 'Valor exacto',
        subtitulo: 'Pago ${formatoPesos(total)} justos',
        elegida: _efectivo == _Efectivo.exacto,
        onTap: () => setState(() => _efectivo = _Efectivo.exacto),
      ),
      for (final b in billetes) ...[
        const SizedBox(height: 10),
        OpcionCard(
          titulo: 'Con ${formatoPesos(b)}',
          subtitulo: b < total ? 'No alcanza para el total' : 'Cambio: ${formatoPesos(b - total)}',
          habilitada: b >= total,
          elegida: _efectivo == _Efectivo.billete && _billete == b,
          onTap: () => setState(() {
            _efectivo = _Efectivo.billete;
            _billete = b;
          }),
        ),
      ],
      const SizedBox(height: 10),
      OpcionCard(
        titulo: 'Otro valor',
        elegida: _efectivo == _Efectivo.otro,
        onTap: () => setState(() => _efectivo = _Efectivo.otro),
      ),
      if (_efectivo == _Efectivo.otro) ...[
        const SizedBox(height: 12),
        AppInput(
          label: '¿Con cuánto pagas?',
          hint: 'Ej: 30000',
          controller: _otroController,
          keyboardType: TextInputType.number,
          errorText: _otroError,
        ),
      ],
      if (_efectivo != _Efectivo.exacto && cambio != null) ...[
        const SizedBox(height: 14),
        MessageBanner(
          title: 'Tu cambio: ${formatoPesos(cambio)}',
          subtitle: 'El domiciliario lleva el cambio.',
        ),
      ],
    ];
  }

  /// 08d · Transferencia: a qué cuenta, con el número y el titular.
  List<Widget> _opcionesTransferencia(List<EntidadPago> entidades, int total) {
    return [
      for (final e in entidades) ...[
        OpcionCard(
          titulo: e.nombre,
          subtitulo: '${e.datoDestino} · ${e.titular}',
          icono: Icons.account_balance_outlined,
          elegida: _entidad?.id == e.id,
          onTap: () => setState(() {
            _entidad = e;
            _entidadError = null;
          }),
        ),
        const SizedBox(height: 10),
      ],
      if (_entidadError != null) _ErrorTexto(_entidadError!),
      if (_entidad != null) ...[
        const SizedBox(height: 4),
        MessageBanner(
          title: 'Transfiere ${formatoPesos(total)} a ${_entidad!.nombre}',
          subtitle:
              '${_entidad!.datoDestino} · ${_entidad!.titular}. '
              'Muestra el comprobante al recibir.',
        ),
      ],
    ];
  }
}

/// Mientras llegan zonas y entidades; si falla, permite reintentar.
class _Cargando extends StatelessWidget {
  final DatosEntregaState state;

  const _Cargando({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.status != DatosEntregaStatus.failure) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MessageBanner(title: state.errorMessage!, isError: true),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Reintentar',
            isSecondary: true,
            onPressed: () => context.read<DatosEntregaBloc>().add(DatosEntregaRequested()),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String texto;

  const _Seccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text),
      ),
    );
  }
}

class _ErrorTexto extends StatelessWidget {
  final String texto;

  const _ErrorTexto(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.error)),
    );
  }
}

class _MetodoChip extends StatelessWidget {
  final String texto;
  final bool activo;
  final Function() onTap;

  const _MetodoChip({required this.texto, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(texto),
      selected: activo,
      showCheckmark: false,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: activo ? AppColors.onPrimary : AppColors.text,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
