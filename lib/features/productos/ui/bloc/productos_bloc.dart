import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/cambiar_disponibilidad_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/watch_productos_usecase.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_event.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_state.dart';

/// Disponibilidad de productos del domiciliario (19), en tiempo real.
///
/// El switch no cambia la lista a mano: guarda en Supabase y el Stream trae
/// el producto actualizado, igual que le llega al menú del cliente.
class ProductosBloc extends Bloc<ProductosEvent, ProductosState> {
  final WatchProductosUseCase _watchProductos;
  final CambiarDisponibilidadUseCase _cambiarDisponibilidad;

  StreamSubscription<List<Producto>>? _subscription;

  ProductosBloc(this._watchProductos, this._cambiarDisponibilidad)
    : super(const ProductosState()) {
    on<ProductosStarted>(_onStarted);
    on<ProductosUpdated>(_onUpdated);
    on<ProductosStreamFailed>(_onStreamFailed);
    on<DisponibilidadCambiada>(_onDisponibilidadCambiada);
  }

  void _onStarted(ProductosStarted event, Emitter<ProductosState> emit) {
    emit(state.copyWith(status: ProductosStatus.loading));
    _subscription?.cancel();
    _subscription = _watchProductos().listen(
      (productos) => add(ProductosUpdated(productos)),
      onError: (Object error) => add(ProductosStreamFailed('$error')),
    );
  }

  void _onUpdated(ProductosUpdated event, Emitter<ProductosState> emit) {
    emit(state.copyWith(status: ProductosStatus.success, productos: event.productos));
  }

  void _onStreamFailed(ProductosStreamFailed event, Emitter<ProductosState> emit) {
    emit(state.copyWith(status: ProductosStatus.failure, errorMessage: event.message));
  }

  Future<void> _onDisponibilidadCambiada(
    DisponibilidadCambiada event,
    Emitter<ProductosState> emit,
  ) async {
    final id = event.producto.id;
    emit(state.copyWith(guardando: {...state.guardando, id}));
    try {
      await _cambiarDisponibilidad(id, disponible: event.disponible);
      emit(state.copyWith(guardando: {...state.guardando}..remove(id)));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          guardando: {...state.guardando}..remove(id),
          errorMessage: '$e',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
