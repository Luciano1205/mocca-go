import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/auth/data/repository/auth_repository_impl.dart';
import 'package:mocca_go/features/auth/data/repository/usuario_repository_impl.dart';
import 'package:mocca_go/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:mocca_go/features/auth/data/source/supabase_usuario_data_source.dart';
import 'package:mocca_go/features/auth/domain/repository/auth_repository.dart';
import 'package:mocca_go/features/auth/domain/repository/usuario_repository.dart';
import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/send_recovery_code_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mocca_go/features/catalogo/data/repository/catalogo_repository_impl.dart';
import 'package:mocca_go/features/catalogo/data/source/supabase_catalogo_data_source.dart';
import 'package:mocca_go/features/catalogo/domain/repository/catalogo_repository.dart';
import 'package:mocca_go/features/common/ui/screens/coming_soon_screen.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_bloc.dart';
import 'package:mocca_go/features/detalle_pedido/ui/screens/detalle_pedido_screen.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_bloc.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/screens/gestionar_pedido_screen.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/login/ui/screens/login_screen.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/screens/cliente_panel_screen.dart';
import 'package:mocca_go/features/panel/ui/screens/proveedor_panel_screen.dart';
import 'package:mocca_go/features/pedidos/data/repository/pedido_repository_impl.dart';
import 'package:mocca_go/features/pedidos/data/source/supabase_pedido_data_source.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pedidos/domain/repository/pedido_repository.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/avanzar_pedido_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_mis_entregas_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/get_pedidos_pendientes_usecase.dart';
import 'package:mocca_go/features/pedidos/domain/usecases/tomar_pedido_usecase.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_bloc.dart';
import 'package:mocca_go/features/recovery/ui/screens/new_password_screen.dart';
import 'package:mocca_go/features/recovery/ui/screens/recover_screen.dart';
import 'package:mocca_go/features/register/ui/bloc/register_bloc.dart';
import 'package:mocca_go/features/register/ui/screens/register_client_screen.dart';
import 'package:mocca_go/features/register/ui/screens/register_provider_screen.dart';
import 'package:mocca_go/features/register/ui/screens/register_type_screen.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_bloc.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_event.dart';
import 'package:mocca_go/features/splash/ui/screens/splash_screen.dart';
import 'package:mocca_go/routes/app_routes.dart';
import 'package:mocca_go/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La URL y la publishable key son públicas por diseño. La seguridad
  // la dan las políticas RLS de la base de datos.
  await Supabase.initialize(
    url: 'https://hrssifllllrayalbcpsk.supabase.co',
    publishableKey: 'sb_publishable_Vk3CvI2i--JVI5aQ4xl-7Q_ue6vf2xi',
  );
  final client = Supabase.instance.client;
  runApp(
    App(
      auth: AuthRepositoryImpl(SupabaseAuthDataSource(client)),
      usuarios: UsuarioRepositoryImpl(SupabaseUsuarioDataSource(client)),
      catalogo: CatalogoRepositoryImpl(SupabaseCatalogoDataSource(client)),
      pedidos: PedidoRepositoryImpl(SupabasePedidoDataSource(client)),
    ),
  );
}

/// Widget raíz: tema y tabla de rutas con nombre.
///
/// Recibe los repositorios ya construidos: [main] le pasa los de Supabase y
/// las pruebas le pasan falsos. Cada ruta arma su Bloc con sus casos de uso.
class App extends StatelessWidget {
  final AuthRepository auth;
  final UsuarioRepository usuarios;
  final CatalogoRepository catalogo;
  final PedidoRepository pedidos;

  const App({
    super.key,
    required this.auth,
    required this.usuarios,
    required this.catalogo,
    required this.pedidos,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocca Go!',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => BlocProvider(
          create: (_) =>
              SplashBloc(GetSessionUseCase(auth, usuarios))
                ..add(SplashStarted()),
          child: const SplashScreen(),
        ),
        AppRoutes.login: (_) => BlocProvider(
          create: (_) => LoginBloc(SignInUseCase(auth, usuarios)),
          child: const LoginScreen(),
        ),
        AppRoutes.tipoRegistro: (_) => const RegisterTypeScreen(),
        AppRoutes.registroCliente: (_) => BlocProvider(
          create: (_) => RegisterBloc(SignUpUseCase(auth)),
          child: const RegisterClientScreen(),
        ),
        AppRoutes.registroDomiciliario: (_) => BlocProvider(
          create: (_) => RegisterBloc(SignUpUseCase(auth)),
          child: const RegisterProviderScreen(),
        ),
        AppRoutes.recuperar: (_) => BlocProvider(
          create: (_) => RecoverBloc(SendRecoveryCodeUseCase(auth)),
          child: const RecoverScreen(),
        ),
        AppRoutes.nuevaContrasena: (_) => BlocProvider(
          create: (_) => NewPasswordBloc(
            ResetPasswordUseCase(auth),
            SendRecoveryCodeUseCase(auth),
          ),
          child: const NewPasswordScreen(),
        ),
        AppRoutes.panelCliente: (context) => BlocProvider(
          create: (_) => PanelBloc(SignOutUseCase(auth)),
          child: ClientePanelScreen(usuario: _usuario(context)),
        ),
        AppRoutes.panelProveedor: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => PanelBloc(SignOutUseCase(auth))),
            BlocProvider(
              create: (_) => PendientesBloc(GetPedidosPendientesUseCase(pedidos)),
            ),
            BlocProvider(
              create: (_) => MisEntregasBloc(GetMisEntregasUseCase(pedidos)),
            ),
          ],
          child: ProveedorPanelScreen(usuario: _usuario(context)),
        ),
        // Soporte atiende reclamos en el sprint 3; por ahora solo su perfil.
        AppRoutes.panelSoporte: (context) => BlocProvider(
          create: (_) => PanelBloc(SignOutUseCase(auth)),
          child: Scaffold(
            body: SafeArea(child: PerfilPage(usuario: _usuario(context))),
          ),
        ),
        AppRoutes.detallePedido: (context) => BlocProvider(
          create: (_) => DetallePedidoBloc(TomarPedidoUseCase(pedidos), _pedido(context)),
          child: const DetallePedidoScreen(),
        ),
        AppRoutes.gestionarPedido: (context) => BlocProvider(
          create: (_) =>
              GestionarPedidoBloc(AvanzarPedidoUseCase(pedidos), _pedido(context)),
          child: const GestionarPedidoScreen(),
        ),
      },
      // Rutas que aún no existen.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => ComingSoonScreen(routeName: settings.name ?? ''),
      ),
    );
  }

  /// Los paneles reciben el [Usuario] como argumento (login o splash).
  Usuario _usuario(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Usuario;
  }

  /// Detalle y Gestionar reciben el [Pedido] como argumento.
  Pedido _pedido(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Pedido;
  }
}
