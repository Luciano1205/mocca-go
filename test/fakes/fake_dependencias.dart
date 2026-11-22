import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';
import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';
import 'package:mocca_go/injection_container.dart';

/// Registra los repositorios falsos en GetIt en lugar de los de Supabase, y
/// después los casos de uso y Blocs reales con [registrarDominioYUi]. Así la
/// App de las pruebas es la misma de producción, solo cambia el origen de
/// los datos.
void registrarFakes({
  required AuthRepository auth,
  required UsuarioRepository usuarios,
  required CatalogoRepository catalogo,
  required PedidoRepository pedidos,
  required CalificacionRepository calificaciones,
  required ReclamoRepository reclamos,
}) {
  // Cada prueba vuelve a registrar con sus propios falsos.
  sl.allowReassignment = true;
  sl.registerLazySingleton<AuthRepository>(() => auth);
  sl.registerLazySingleton<UsuarioRepository>(() => usuarios);
  sl.registerLazySingleton<CatalogoRepository>(() => catalogo);
  sl.registerLazySingleton<PedidoRepository>(() => pedidos);
  sl.registerLazySingleton<CalificacionRepository>(() => calificaciones);
  sl.registerLazySingleton<ReclamoRepository>(() => reclamos);
  registrarDominioYUi();
}
