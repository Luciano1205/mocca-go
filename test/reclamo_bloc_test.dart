import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/pedidos/domain/entities/estado_pedido.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_bloc.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_event.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_state.dart';
import 'package:mocca_go/features/reclamos/domain/entities/reclamo.dart';
import 'package:mocca_go/features/reclamos/domain/errors/reclamo_failure.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/abrir_reclamo_usecase.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/get_motivos_reclamo_usecase.dart';

import 'fakes/fake_complementos.dart';

/// Falla el primer envío, como si se cayera la conexión.
class _ReclamoQueFallaUnaVez extends FakeReclamoRepository {
  bool fallo = false;

  @override
  Future<Reclamo> abrir(NuevoReclamo reclamo) async {
    if (!fallo) {
      fallo = true;
      throw const ReclamoFailure('No se pudo registrar tu reclamo. Intenta de nuevo.');
    }
    return super.abrir(reclamo);
  }
}

void main() {
  Pedido pedido(EstadoPedido estado) => Pedido(
    id: 'p1',
    numero: 1042,
    estado: estado,
    clienteNombre: 'Laura Gómez',
    zona: 'Edificio D',
    referencia: 'Salón 204',
    items: const [
      ItemPedido(id: 'd1', nombre: 'Capuchino', precioUnitario: 6500, cantidad: 1, subtotal: 6500),
      ItemPedido(id: 'd2', nombre: 'Pandebono', precioUnitario: 3000, cantidad: 2, subtotal: 6000),
    ],
    subtotal: 12500,
    total: 12500,
    creadoEn: DateTime(2026, 11, 23),
  );

  ReclamoBloc crear(FakeReclamoRepository repo, EstadoPedido estado) =>
      ReclamoBloc(GetMotivosReclamoUseCase(repo), AbrirReclamoUseCase(repo), pedido(estado));

  Future<void> esperar() => Future<void>.delayed(Duration.zero);

  test('Saluda con el número del pedido y los motivos según su estado', () async {
    final bloc = crear(FakeReclamoRepository(), EstadoPedido.enCamino);
    bloc.add(ReclamoStarted());
    await esperar();
    expect(bloc.state.paso, PasoReclamo.motivo);
    expect(bloc.state.mensajes.first.texto, contains('#1042'));
    expect(bloc.state.mensajes.last.texto, '¿Qué pasó?');
    expect(bloc.state.motivos.map((m) => m.id), ['no-llega', 'demora']);
    await bloc.close();
  });

  test('Faltó un producto: pregunta producto y solución y registra', () async {
    final repo = FakeReclamoRepository();
    final bloc = crear(repo, EstadoPedido.entregado);
    bloc.add(ReclamoStarted());
    await esperar();
    final falto = bloc.state.motivos.firstWhere((m) => m.id == 'falto');

    bloc.add(MotivoElegido(falto));
    await esperar();
    expect(bloc.state.paso, PasoReclamo.producto);

    bloc.add(ProductosElegidos(bloc.state.pedido.items));
    await esperar();
    expect(bloc.state.paso, PasoReclamo.solucion);
    expect(bloc.state.mensajes.where((m) => !m.delBot).last.texto, 'Capuchino, Pandebono');

    bloc.add(SolucionElegida(SolucionReclamo.devolver));
    await esperar();
    expect(bloc.state.paso, PasoReclamo.listo);
    expect(bloc.state.reclamo!.codigo, 'R-101');
    expect(repo.abiertos.single.detalleIds, ['d1', 'd2']);
    expect(repo.abiertos.single.solucion, SolucionReclamo.devolver);
    await bloc.close();
  });

  test('Si falla el envío, el bot lo dice y deja reintentar', () async {
    final repo = _ReclamoQueFallaUnaVez();
    final bloc = crear(repo, EstadoPedido.enCamino);
    bloc.add(ReclamoStarted());
    await esperar();

    bloc.add(MotivoElegido(bloc.state.motivos.first));
    await esperar();
    expect(bloc.state.paso, PasoReclamo.error);
    expect(bloc.state.mensajes.last.texto, 'No se pudo registrar tu reclamo. Intenta de nuevo.');

    bloc.add(ReclamoReintentado());
    await esperar();
    expect(bloc.state.paso, PasoReclamo.listo);
    expect(repo.abiertos.length, 1);
    await bloc.close();
  });

  test('Un pedido cancelado no tiene reclamos', () async {
    final bloc = crear(FakeReclamoRepository(), EstadoPedido.cancelado);
    bloc.add(ReclamoStarted());
    await esperar();
    expect(bloc.state.paso, PasoReclamo.error);
    expect(bloc.state.mensajes.single.texto, 'Los pedidos cancelados no tienen reclamos.');
    await bloc.close();
  });

  test('Un toque doble no registra dos reclamos', () async {
    final repo = FakeReclamoRepository();
    final bloc = crear(repo, EstadoPedido.enCamino);
    bloc.add(ReclamoStarted());
    await esperar();

    final motivo = bloc.state.motivos.first;
    bloc
      ..add(MotivoElegido(motivo))
      ..add(MotivoElegido(motivo));
    await esperar();
    expect(repo.abiertos.length, 1);
    expect(bloc.state.mensajes.where((m) => !m.delBot).length, 1);
    await bloc.close();
  });
}
