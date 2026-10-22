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
import 'package:mocca_go/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mocca_go/features/common/ui/screens/coming_soon_screen.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/login/ui/screens/login_screen.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/screens/panel_screen.dart';
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
              SplashBloc(GetSessionUseCase(auth, usuarios))..add(SplashStarted()),
          child: const SplashScreen(),
        ),
        AppRoutes.login: (_) => BlocProvider(
          create: (_) => LoginBloc(SignInUseCase(auth, usuarios)),
          child: const LoginScreen(),
        ),
        AppRoutes.panelCliente: _panel,
        AppRoutes.panelProveedor: _panel,
        AppRoutes.panelSoporte: _panel,
      },
      // Rutas que aún no existen (registro y recuperación, en construcción).
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
