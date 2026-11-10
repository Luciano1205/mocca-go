import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/catalogo/domain/usecases/get_categorias_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_productos_usecase.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_event.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_state.dart';

/// Carga el menú del cliente (06 · Menú) y filtra por categoría.
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetCategoriasUseCase _getCategorias;
  final GetProductosUseCase _getProductos;

  MenuBloc(this._getCategorias, this._getProductos) : super(const MenuState()) {
    on<MenuRequested>(_onRequested);
    on<MenuCategoriaSelected>(_onCategoriaSelected);
  }

  Future<void> _onRequested(MenuRequested event, Emitter<MenuState> emit) async {
    final categoriaId = state.categoriaId;
    emit(state.copyWith(status: MenuStatus.loading, categoriaId: categoriaId));
    try {
      final categorias = await _getCategorias();
      final productos = await _getProductos(categoriaId: categoriaId);
      emit(
        state.copyWith(
          status: MenuStatus.success,
          categorias: categorias,
          categoriaId: categoriaId,
          productos: productos,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(status: MenuStatus.failure, categoriaId: categoriaId, errorMessage: '$e'),
      );
    }
  }

  Future<void> _onCategoriaSelected(MenuCategoriaSelected event, Emitter<MenuState> emit) async {
    // Se limpia la lista para no mostrar los productos del chip anterior.
    emit(
      state.copyWith(
        status: MenuStatus.loading,
        categoriaId: event.categoriaId,
        productos: const [],
      ),
    );
    try {
      final productos = await _getProductos(categoriaId: event.categoriaId);
      emit(
        state.copyWith(
          status: MenuStatus.success,
          categoriaId: event.categoriaId,
          productos: productos,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: MenuStatus.failure,
          categoriaId: event.categoriaId,
          errorMessage: '$e',
        ),
      );
    }
  }
}
