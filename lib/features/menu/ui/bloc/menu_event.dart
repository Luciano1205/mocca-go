import 'package:mocca_go/features/catalogo/domain/entities/producto.dart';

/// Eventos del menú (06).
abstract class MenuEvent {}

/// Carga las categorías y abre la suscripción en tiempo real de los
/// productos: al entrar al panel y al deslizar hacia abajo.
class MenuStarted extends MenuEvent {}

/// Se tocó un chip. [categoriaId] null es "Todos". Solo filtra en el Bloc:
/// no abre ni cierra suscripciones.
class MenuCategoriaSelected extends MenuEvent {
  final String? categoriaId;

  MenuCategoriaSelected(this.categoriaId);
}

/// Supabase empujó los productos (por ejemplo, uno se agotó). Solo lo lanza
/// el Bloc.
class MenuProductosUpdated extends MenuEvent {
  final List<Producto> productos;

  MenuProductosUpdated(this.productos);
}

/// El Stream falló. Solo lo lanza el Bloc.
class MenuStreamFailed extends MenuEvent {
  final String message;

  MenuStreamFailed(this.message);
}
