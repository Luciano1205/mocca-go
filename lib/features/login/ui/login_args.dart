/// Aviso verde que se muestra arriba del formulario de login cuando se
/// llega desde otro flujo: "¡Cuenta creada exitosamente!" (02e) o
/// "¡Contraseña actualizada!" (02h).
class LoginArgs {
  final String titulo;
  final String subtitulo;

  const LoginArgs({required this.titulo, required this.subtitulo});

  /// 02e · después de registrarse.
  static const cuentaCreada = LoginArgs(
    titulo: '¡Cuenta creada exitosamente!',
    subtitulo: 'Inicia sesión para continuar.',
  );

  /// 02h · después de recuperar la contraseña.
  static const contrasenaActualizada = LoginArgs(
    titulo: '¡Contraseña actualizada!',
    subtitulo: 'Inicia sesión con tu nueva contraseña.',
  );
}
