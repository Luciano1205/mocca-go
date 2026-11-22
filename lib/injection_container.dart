import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mocca_go/features/auth/data/repository/usuario_repository_impl.dart';
import 'package:mocca_go/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:mocca_go/features/auth/data/source/supabase_usuario_data_source.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';
import 'package:mocca_go/features/auth/domain/usecases/actualizar_perfil_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/send_recovery_code_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mocca_go/features/calificaciones/data/repository/calificacion_repository_impl.dart';
import 'package:mocca_go/features/calificaciones/data/source/supabase_calificacion_data_source.dart';
import 'package:mocca_go/features/calificaciones/domain/repository/calificacion_repository.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/calificar_usecase.dart';
import 'package:mocca_go/features/calificaciones/domain/usecases/get_mi_calificacion_usecase.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/catalogo/data/repository/catalogo_repository_impl.dart';
import 'package:mocca_go/features/catalogo/data/source/supabase_catalogo_data_source.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/cambiar_disponibilidad_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_categorias_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_entidades_pago_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_productos_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/get_zonas_usecase.dart';
import 'package:mocca_go/features/catalogo/domain/usecases/watch_productos_usecase.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_bloc.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_bloc.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_bloc.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_bloc.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/pedidos/data/repository/pedido_repository_impl.dart';
import 'package:mocca_go/features/pedidos/data/source/supabase_pedido_data_source.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/cancelar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/crear_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_pedidos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/tomar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_entregas_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_mis_pedidos_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/watch_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_bloc.dart';
import 'package:mocca_go/features/reclamos/data/repository/reclamo_repository_impl.dart';
import 'package:mocca_go/features/reclamos/data/source/supabase_reclamo_data_source.dart';
import 'package:mocca_go/features/reclamos/domain/repository/reclamo_repository.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/abrir_reclamo_usecase.dart';
import 'package:mocca_go/features/reclamos/domain/usecases/get_motivos_reclamo_usecase.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_bloc.dart';
import 'package:mocca_go/features/register/ui/bloc/register_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_bloc.dart';

/// El registro de dependencias (service locator), como en la lección
/// "Inyección de dependencias con GetIt". Cada objeto se registra una vez al
/// arrancar y cada capa se lo pide a [sl] en vez de crearlo.
///
/// - `registerLazySingleton`: data sources, repositorios y casos de uso. Se
///   crean la primera vez que se piden y después se reutilizan.
/// - `registerFactory`: Blocs. Uno nuevo cada vez, con su propio estado.
/// - `registerFactoryParam`: Blocs que necesitan el pedido o el usuario de
///   la ruta: `sl<SeguimientoBloc>(param1: pedido)`.
///
/// Las clases siguen recibiendo sus dependencias por constructor; aquí es
/// donde GetIt se las entrega con `sl()`. Así los casos de uso solo conocen
/// el contrato del repositorio, nunca su implementación.
final sl = GetIt.instance;

/// Producción: se llama en `main` después de `Supabase.initialize`.
void initDependencies() {
  _registrarDatos();
  registrarDominioYUi();
}

/// Data sources de Supabase y repositorios, registrados bajo el tipo del
/// contrato: quien pide un [PedidoRepository] recibe un [PedidoRepositoryImpl].
void _registrarDatos() {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Data sources
  sl.registerLazySingleton(() => SupabaseAuthDataSource(sl()));
  sl.registerLazySingleton(() => SupabaseUsuarioDataSource(sl()));
  sl.registerLazySingleton(() => SupabaseCatalogoDataSource(sl()));
  sl.registerLazySingleton(() => SupabasePedidoDataSource(sl()));
  sl.registerLazySingleton(() => SupabaseCalificacionDataSource(sl()));
  sl.registerLazySingleton(() => SupabaseReclamoDataSource(sl()));

  // Repositorios
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<UsuarioRepository>(() => UsuarioRepositoryImpl(sl()));
  sl.registerLazySingleton<CatalogoRepository>(() => CatalogoRepositoryImpl(sl()));
  sl.registerLazySingleton<PedidoRepository>(() => PedidoRepositoryImpl(sl()));
  sl.registerLazySingleton<CalificacionRepository>(() => CalificacionRepositoryImpl(sl()));
  sl.registerLazySingleton<ReclamoRepository>(() => ReclamoRepositoryImpl(sl()));
}

/// Casos de uso y Blocs. Solo dependen de los contratos de los repositorios,
/// por eso las pruebas registran repositorios falsos y luego llaman a esta
/// misma función.
void registrarDominioYUi() {
  // ---------- Casos de uso ----------
  // Autenticación y perfil
  sl.registerLazySingleton(() => GetSessionUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl(), sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SendRecoveryCodeUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ActualizarPerfilUseCase(sl()));

  // Catálogo
  sl.registerLazySingleton(() => GetCategoriasUseCase(sl()));
  sl.registerLazySingleton(() => GetProductosUseCase(sl()));
  sl.registerLazySingleton(() => GetZonasUseCase(sl()));
  sl.registerLazySingleton(() => GetEntidadesPagoUseCase(sl()));
  sl.registerLazySingleton(() => WatchProductosUseCase(sl()));
  sl.registerLazySingleton(() => CambiarDisponibilidadUseCase(sl()));

  // Pedidos
  sl.registerLazySingleton(() => CrearPedidoUseCase(sl()));
  sl.registerLazySingleton(() => GetPedidoUseCase(sl()));
  sl.registerLazySingleton(() => GetMisPedidosUseCase(sl()));
  sl.registerLazySingleton(() => CancelarPedidoUseCase(sl()));
  sl.registerLazySingleton(() => TomarPedidoUseCase(sl()));
  sl.registerLazySingleton(() => AvanzarPedidoUseCase(sl()));
  sl.registerLazySingleton(() => WatchPedidosPendientesUseCase(sl()));
  sl.registerLazySingleton(() => WatchMisEntregasUseCase(sl()));
  sl.registerLazySingleton(() => WatchMisPedidosUseCase(sl()));
  sl.registerLazySingleton(() => WatchPedidoUseCase(sl()));

  // Calificaciones y reclamos
  sl.registerLazySingleton(() => CalificarUseCase(sl()));
  sl.registerLazySingleton(() => GetMiCalificacionUseCase(sl()));
  sl.registerLazySingleton(() => GetMotivosReclamoUseCase(sl()));
  sl.registerLazySingleton(() => AbrirReclamoUseCase(sl()));

  // ---------- Blocs ----------
  // Acceso
  sl.registerFactory(() => SplashBloc(sl()));
  sl.registerFactory(() => LoginBloc(sl()));
  sl.registerFactory(() => RegisterBloc(sl()));
  sl.registerFactory(() => RecoverBloc(sl()));
  sl.registerFactory(() => NewPasswordBloc(sl(), sl()));
  sl.registerFactory(() => PanelBloc(sl()));
  sl.registerFactoryParam<EditarPerfilBloc, Usuario, void>(
    (usuario, _) => EditarPerfilBloc(sl(), usuario),
  );

  // Cliente
  sl.registerFactory(() => CarritoBloc());
  sl.registerFactory(() => MenuBloc(sl(), sl()));
  sl.registerFactory(() => MisPedidosBloc(sl()));
  sl.registerFactory(() => DatosEntregaBloc(sl(), sl(), sl()));
  sl.registerFactoryParam<SeguimientoBloc, Pedido, void>(
    (pedido, _) => SeguimientoBloc(sl(), sl(), pedido),
  );

  // Domiciliario
  sl.registerFactory(() => PendientesBloc(sl()));
  sl.registerFactory(() => MisEntregasBloc(sl()));
  sl.registerFactory(() => ProductosBloc(sl(), sl()));
  sl.registerFactoryParam<DetallePedidoBloc, Pedido, void>(
    (pedido, _) => DetallePedidoBloc(sl(), pedido),
  );
  sl.registerFactoryParam<GestionarPedidoBloc, Pedido, void>(
    (pedido, _) => GestionarPedidoBloc(sl(), sl(), sl(), pedido),
  );
}
