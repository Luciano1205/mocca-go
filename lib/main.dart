import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/splash/ui/screens/splash_screen.dart';
import 'package:mocca_go/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La URL y la publishable key son públicas por diseño. La seguridad
  // la dan las políticas RLS de la base de datos.
  await Supabase.initialize(
    url: 'https://hrssifllllrayalbcpsk.supabase.co',
    publishableKey: 'sb_publishable_Vk3CvI2i--JVI5aQ4xl-7Q_ue6vf2xi',
  );
  runApp(const App());
}

/// Widget raíz: tema y tabla de rutas con nombre.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mocca Go!',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
      },
    );
  }
}
