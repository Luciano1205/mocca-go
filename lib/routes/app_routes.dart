import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

/// Nombres de las rutas de la app, en un solo lugar.
class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const tipoRegistro = '/tipo-registro';
  static const registroCliente = '/registro-cliente';
  static const registroDomiciliario = '/registro-domiciliario';
  static const recuperar = '/recuperar';
  static const nuevaContrasena = '/nueva-contrasena';
  static const panelCliente = '/cliente';
  static const panelProveedor = '/proveedor';
  static const panelSoporte = '/soporte';

  /// Panel al que entra cada rol después del login o del splash.
  static String panelDe(Rol rol) {
    switch (rol) {
      case Rol.cliente:
        return panelCliente;
      case Rol.proveedor:
        return panelProveedor;
      case Rol.soporte:
        return panelSoporte;
    }
  }
}
