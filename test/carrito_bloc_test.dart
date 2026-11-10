import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

void main() {
  const capuchino = Producto(
    id: 'capuchino',
    categoriaId: 'cafes',
    nombre: 'Capuchino',
    precio: 6500,
  );
  const pandebono = Producto(
    id: 'pandebono',
    categoriaId: 'snacks',
    nombre: 'Pandebono',
    precio: 3000,
  );

  late CarritoBloc bloc;

  setUp(() => bloc = CarritoBloc());
  tearDown(() => bloc.close());

  /// Manda los eventos y espera a que el Bloc los procese.
  Future<void> enviar(List<CarritoEvent> eventos) async {
    for (final e in eventos) {
      bloc.add(e);
    }
    await Future<void>.delayed(Duration.zero);
  }

  test('Empieza vacío', () {
    expect(bloc.state.vacio, isTrue);
    expect(bloc.state.total, 0);
  });

  test('Suma unidades del mismo producto y calcula el total', () async {
    await enviar([
      CarritoProductoAgregado(capuchino),
      CarritoProductoAgregado(capuchino),
      CarritoProductoAgregado(pandebono),
    ]);
    expect(bloc.state.items.length, 2);
    expect(bloc.state.cantidadDe('capuchino'), 2);
    expect(bloc.state.totalUnidades, 3);
    expect(bloc.state.total, 16000);
  });

  test('Restar la última unidad saca el producto', () async {
    await enviar([
      CarritoProductoAgregado(capuchino),
      CarritoProductoAgregado(pandebono),
      CarritoProductoQuitado('capuchino'),
    ]);
    expect(bloc.state.cantidadDe('capuchino'), 0);
    expect(bloc.state.items.single.producto.id, 'pandebono');
  });

  test('Arma las líneas del pedido con cantidad y precio', () async {
    await enviar([CarritoProductoAgregado(capuchino), CarritoProductoAgregado(capuchino)]);
    final linea = bloc.state.lineas.single;
    expect(linea.productoId, 'capuchino');
    expect(linea.cantidad, 2);
    expect(linea.precioUnitario, 6500);
    expect(linea.subtotal, 13000);
  });

  test('Vaciar deja el carrito en cero', () async {
    await enviar([CarritoProductoAgregado(capuchino), CarritoVaciado()]);
    expect(bloc.state.vacio, isTrue);
  });
}
