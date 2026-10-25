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
import 'package:mocca_go/features/common/ui/screens/coming_soon_screen.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/login/ui/screens/login_screen.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/screens/panel_screen.dart';
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

  const App({super.key, required this.auth, required this.usuarios});

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
        AppRoutes.panelCliente: _panel,
        AppRoutes.panelProveedor: _panel,
        AppRoutes.panelSoporte: _panel,
      },
      // Rutas que aún no existen.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => ComingSoonScreen(routeName: settings.name ?? ''),
      ),
    );
  }

  /// Panel temporal de cada rol; recibe el [Usuario] como argumento.
  Widget _panel(BuildContext context) {
    final usuario = ModalRoute.of(context)!.settings.arguments as Usuario;
    return BlocProvider(
      create: (_) => PanelBloc(SignOutUseCase(auth)),
      child: PanelScreen(usuario: usuario),
    );
  }
}
