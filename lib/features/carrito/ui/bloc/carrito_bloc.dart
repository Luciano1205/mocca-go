import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/carrito/ui/bloc/carrito_event.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_state.dart';

/// Carrito del cliente (07 · Carrito). Vive por encima del MaterialApp para
/// que Menú, Carrito y Datos de entrega vean el mismo.
///
/// No usa casos de uso: solo suma y resta en memoria. El pedido se crea en
/// Datos de entrega con las [CarritoState.lineas].
class CarritoBloc extends Bloc<CarritoEvent, CarritoState> {
  CarritoBloc() : super(const CarritoState()) {
    on<CarritoProductoAgregado>(_onAgregado);
    on<CarritoProductoQuitado>(_onQuitado);
    on<CarritoVaciado>((event, emit) => emit(const CarritoState()));
  }

  void _onAgregado(CarritoProductoAgregado event, Emitter<CarritoState> emit) {
    final items = [...state.items];
    final i = items.indexWhere((item) => item.producto.id == event.producto.id);
    if (i == -1) {
      items.add(ItemCarrito(producto: event.producto, cantidad: 1));
    } else {
      items[i] = ItemCarrito(producto: items[i].producto, cantidad: items[i].cantidad + 1);
    }
    emit(state.copyWith(items: items));
  }

  void _onQuitado(CarritoProductoQuitado event, Emitter<CarritoState> emit) {
    final items = [...state.items];
    final i = items.indexWhere((item) => item.producto.id == event.productoId);
    if (i == -1) return;
    if (items[i].cantidad == 1) {
      items.removeAt(i);
    } else {
      items[i] = ItemCarrito(producto: items[i].producto, cantidad: items[i].cantidad - 1);
    }
    emit(state.copyWith(items: items));
  }
}
