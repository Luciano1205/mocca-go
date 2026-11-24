import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_categorias_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/watch_productos_usecase.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_event.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_state.dart';
import 'package:mocca_go/utils/reconexion.dart';

/// Menú del cliente (06) en tiempo real: si el domiciliario agota un
/// producto, aparece deshabilitado al instante.
///
/// Las categorías se cargan una vez porque no cambian. Los productos se
/// escuchan todos con una sola suscripción y el chip solo filtra.
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetCategoriasUseCase _getCategorias;
  final WatchProductosUseCase _watchProductos;

  /// Cuánto esperar para reconectar; solo cambia en las pruebas.
  final Duration espera;

  StreamSubscription<List<Producto>>? _subscription;

  /// Reconexión programada después de un error.
  Timer? _reconexion;

  MenuBloc(this._getCategorias, this._watchProductos, {this.espera = esperaReconexion})
    : super(const MenuState()) {
    on<MenuStarted>(_onStarted);
    on<MenuCategoriaSelected>(_onCategoriaSelected);
    on<MenuProductosUpdated>(_onProductosUpdated);
    on<MenuStreamFailed>(_onStreamFailed);
  }

  Future<void> _onStarted(MenuStarted event, Emitter<MenuState> emit) async {
    _reconexion?.cancel();
    final categoriaId = state.categoriaId;
    emit(state.copyWith(status: MenuStatus.loading, categoriaId: categoriaId));
    try {
      final categorias = await _getCategorias();
      emit(state.copyWith(categorias: categorias, categoriaId: categoriaId));
    } on Exception {
      // Sin categorías no se puede mostrar el menú: se reintenta solo.
      add(MenuStreamFailed(mensajeSinConexion));
      return;
    }
    // Sin await: cancel() corta los avisos de inmediato, y en las pruebas
    // de widgets (tiempo simulado) esperar su Future no termina nunca.
    _subscription?.cancel();
    _subscription = _watchProductos().listen(
      (productos) => add(MenuProductosUpdated(productos)),
      onError: (Object error) => add(MenuStreamFailed(mensajeSinConexion)),
    );
  }

  void _onCategoriaSelected(MenuCategoriaSelected event, Emitter<MenuState> emit) {
    emit(state.copyWith(categoriaId: event.categoriaId));
  }

  void _onProductosUpdated(MenuProductosUpdated event, Emitter<MenuState> emit) {
    emit(
      state.copyWith(
        status: MenuStatus.success,
        categoriaId: state.categoriaId,
        todos: event.productos,
      ),
    );
  }

  /// Los productos que ya había se quedan y en [espera] se vuelve a
  /// suscribir. Al llegar datos, [_onProductosUpdated] quita el aviso.
  void _onStreamFailed(MenuStreamFailed event, Emitter<MenuState> emit) {
    emit(
      state.copyWith(
        status: MenuStatus.failure,
        categoriaId: state.categoriaId,
        errorMessage: event.message,
      ),
    );
    _reconexion?.cancel();
    _reconexion = Timer(espera, () {
      if (!isClosed) add(MenuStarted());
    });
  }

  @override
  Future<void> close() async {
    _reconexion?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
