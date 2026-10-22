/// Rol del usuario. Decide a qué panel entra después del login.
enum Rol { cliente, proveedor, soporte }

/// Perfil del usuario (tabla `usuario`). Lo crea la base de datos al
/// registrarse, con el rol según el código de acceso.
class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final Rol rol;
  final String? descripcion;
  final double calificacionPromedio;
  final int totalCalificaciones;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.descripcion,
    this.calificacionPromedio = 0,
    this.totalCalificaciones = 0,
  });
}
