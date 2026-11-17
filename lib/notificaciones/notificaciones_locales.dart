import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Muestra las notificaciones de Mocca Go! con la app abierta.
///
/// Es la parte de "Recibir notificaciones en Flutter" que muestra el aviso
/// (flutter_local_notifications). Quien dispara el aviso no es FCM sino
/// Supabase Realtime: el Bloc ve el cambio en el Stream y la pantalla llama
/// a [mostrar]. Así funciona igual en el simulador de iPhone, sin la llave de
/// APNs. Eventos: nuevo pedido (domiciliarios) y cambio de estado (cliente).
class NotificacionesLocales {
  static const _channel = AndroidNotificationChannel(
    'pedidos',
    'Pedidos',
    description: 'Nuevos pedidos y cambios de estado',
    importance: Importance.max,
  );
  static final _local = FlutterLocalNotificationsPlugin();

  /// En las pruebas no se llama a [init], y [mostrar] no hace nada.
  static bool _listo = false;

  static Future<void> init() async {
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Pide el permiso en iPhone al iniciar la app.
        iOS: DarwinInitializationSettings(),
      ),
    );
    final android = _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);
    // Diálogo de permiso de Android 13 o superior.
    await android?.requestNotificationsPermission();
    _listo = true;
  }

  static Future<void> mostrar({required String titulo, required String cuerpo}) async {
    if (!_listo) return;
    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: titulo,
      body: cuerpo,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
        ),
        // Con la app abierta, iPhone solo la muestra si se pide explícitamente.
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      ),
    );
  }
}
