import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/carrito/ui/bloc/carrito_bloc.dart';
import 'package:mocca_go/features/carrito/ui/screens/carrito_screen.dart';
import 'package:mocca_go/features/common/ui/screens/coming_soon_screen.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_bloc.dart';
import 'package:mocca_go/features/datos_entrega/ui/bloc/datos_entrega_event.dart';
import 'package:mocca_go/features/datos_entrega/ui/screens/datos_entrega_screen.dart';
import 'package:mocca_go/features/detalle_pedido/ui/bloc/detalle_pedido_bloc.dart';
import 'package:mocca_go/features/detalle_pedido/ui/screens/detalle_pedido_screen.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_bloc.dart';
import 'package:mocca_go/features/editar_perfil/ui/screens/editar_perfil_screen.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_bloc.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/bloc/gestionar_pedido_event.dart';
import 'package:mocca_go/features/gestionar_pedido/ui/screens/gestionar_pedido_screen.dart';
import 'package:mocca_go/features/login/ui/bloc/login_bloc.dart';
import 'package:mocca_go/features/login/ui/screens/login_screen.dart';
import 'package:mocca_go/features/menu/ui/bloc/menu_bloc.dart';
import 'package:mocca_go/features/mis_entregas/ui/bloc/mis_entregas_bloc.dart';
import 'package:mocca_go/features/mis_pedidos/ui/bloc/mis_pedidos_bloc.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_bloc.dart';
import 'package:mocca_go/features/panel/ui/pages/perfil_page.dart';
import 'package:mocca_go/features/panel/ui/screens/cliente_panel_screen.dart';
import 'package:mocca_go/features/panel/ui/screens/proveedor_panel_screen.dart';
import 'package:mocca_go/features/pedido_enviado/ui/screens/pedido_enviado_screen.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';
import 'package:mocca_go/features/pendientes/ui/bloc/pendientes_bloc.dart';
import 'package:mocca_go/features/productos/ui/bloc/productos_bloc.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_bloc.dart';
import 'package:mocca_go/features/reclamo_chat/ui/bloc/reclamo_event.dart';
import 'package:mocca_go/features/reclamo_chat/ui/screens/reclamo_screen.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_bloc.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_bloc.dart';
import 'package:mocca_go/features/recovery/ui/screens/new_password_screen.dart';
import 'package:mocca_go/features/recovery/ui/screens/recover_screen.dart';
import 'package:mocca_go/features/register/ui/bloc/register_bloc.dart';
import 'package:mocca_go/features/register/ui/screens/register_client_screen.dart';
import 'package:mocca_go/features/register/ui/screens/register_provider_screen.dart';
import 'package:mocca_go/features/register/ui/screens/register_type_screen.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_bloc.dart';
import 'package:mocca_go/features/seguimiento/ui/bloc/seguimiento_event.dart';
import 'package:mocca_go/features/seguimiento/ui/screens/detalle_mi_pedido_screen.dart';
import 'package:mocca_go/features/seguimiento/ui/screens/seguimiento_screen.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_bloc.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_event.dart';
import 'package:mocca_go/features/splash/ui/screens/splash_screen.dart';
import 'package:mocca_go/injection_container.dart';
import 'package:mocca_go/notificaciones/notificaciones_locales.dart';
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
  // GetIt: se registra todo una vez, después de Supabase y antes de runApp.
  initDependencies();
  await NotificacionesLocales.init();
  runApp(const App());
}

/// Widget raíz: tema y tabla de rutas con nombre.
///
/// Cada ruta le pide su Bloc a GetIt ([sl]) en vez de armarlo: el registro
/// está en `injection_container.dart`. Las pruebas registran repositorios
/// falsos antes de crear la App.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // El carrito va por encima del MaterialApp para que lo compartan
    // Menú, Carrito y Datos de entrega, que son rutas distintas.
    return BlocProvider(
      create: (_) => sl<CarritoBloc>(),
      child: _materialApp(),
    );
  }

  Widget _materialApp() {
    return MaterialApp(
      title: 'Mocca Go!',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => BlocProvider(
          create: (_) => sl<SplashBloc>()..add(SplashStarted()),
          child: const SplashScreen(),
        ),
        AppRoutes.login: (_) => BlocProvider(
          create: (_) => sl<LoginBloc>(),
          child: const LoginScreen(),
        ),
        AppRoutes.tipoRegistro: (_) => const RegisterTypeScreen(),
        AppRoutes.registroCliente: (_) => BlocProvider(
          create: (_) => sl<RegisterBloc>(),
          child: const RegisterClientScreen(),
        ),
        AppRoutes.registroDomiciliario: (_) => BlocProvider(
          create: (_) => sl<RegisterBloc>(),
          child: const RegisterProviderScreen(),
        ),
        AppRoutes.recuperar: (_) => BlocProvider(
          create: (_) => sl<RecoverBloc>(),
          child: const RecoverScreen(),
        ),
        AppRoutes.nuevaContrasena: (_) => BlocProvider(
          create: (_) => sl<NewPasswordBloc>(),
          child: const NewPasswordScreen(),
        ),
        AppRoutes.panelCliente: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<PanelBloc>()),
            BlocProvider(create: (_) => sl<MenuBloc>()),
            BlocProvider(create: (_) => sl<MisPedidosBloc>()),
          ],
          child: ClientePanelScreen(usuario: _usuario(context)),
        ),
        AppRoutes.carrito: (_) => const CarritoScreen(),
        AppRoutes.datosEntrega: (_) => BlocProvider(
          create: (_) => sl<DatosEntregaBloc>()..add(DatosEntregaRequested()),
          child: const DatosEntregaScreen(),
        ),
        AppRoutes.pedidoEnviado: (_) => const PedidoEnviadoScreen(),
        AppRoutes.seguimiento: (context) => BlocProvider(
          create: (_) =>
              sl<SeguimientoBloc>(param1: _pedido(context))..add(SeguimientoStarted()),
          child: const SeguimientoScreen(),
        ),
        // Mismo Bloc del seguimiento: así se puede calificar desde el historial.
        AppRoutes.detalleMiPedido: (context) => BlocProvider(
          create: (_) =>
              sl<SeguimientoBloc>(param1: _pedido(context))..add(SeguimientoStarted()),
          child: const DetalleMiPedidoScreen(),
        ),
        AppRoutes.reclamo: (context) => BlocProvider(
          create: (_) => sl<ReclamoBloc>(param1: _pedido(context))..add(ReclamoStarted()),
          child: const ReclamoScreen(),
        ),
        AppRoutes.panelProveedor: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<PanelBloc>()),
            BlocProvider(create: (_) => sl<PendientesBloc>()),
            BlocProvider(create: (_) => sl<MisEntregasBloc>()),
            BlocProvider(create: (_) => sl<ProductosBloc>()),
          ],
          child: ProveedorPanelScreen(usuario: _usuario(context)),
        ),
        // Soporte atiende reclamos en el sprint 3; por ahora solo su perfil.
        AppRoutes.panelSoporte: (context) => BlocProvider(
          create: (_) => sl<PanelBloc>(),
          child: Scaffold(
            body: SafeArea(
              child: PerfilPage(usuario: _usuario(context), onUsuarioActualizado: (_) {}),
            ),
          ),
        ),
        AppRoutes.editarPerfil: (context) => BlocProvider(
          create: (_) => sl<EditarPerfilBloc>(param1: _usuario(context)),
          child: const EditarPerfilScreen(),
        ),
        AppRoutes.detallePedido: (context) => BlocProvider(
          create: (_) => sl<DetallePedidoBloc>(param1: _pedido(context)),
          child: const DetallePedidoScreen(),
        ),
        AppRoutes.gestionarPedido: (context) => BlocProvider(
          create: (_) =>
              sl<GestionarPedidoBloc>(param1: _pedido(context))..add(GestionarPedidoStarted()),
          child: const GestionarPedidoScreen(),
        ),
      },
      // Rutas que aún no existen.
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => ComingSoonScreen(routeName: settings.name ?? ''),
      ),
    );
  }

  /// Los paneles y Editar perfil reciben el [Usuario] como argumento.
  Usuario _usuario(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Usuario;
  }

  /// Seguimiento, Detalle, Reclamo y Gestionar reciben el [Pedido] como argumento.
  Pedido _pedido(BuildContext context) {
    return ModalRoute.of(context)!.settings.arguments as Pedido;
  }
}
