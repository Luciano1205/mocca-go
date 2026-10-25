/// Lo que las pantallas de registro (04 y 05) le dicen a [RegisterBloc].
abstract class RegisterEvent {}

/// El usuario llenó el formulario y tocó "Crear cuenta". Si trae
/// [codigoAcceso] se registra como domiciliario.
class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String password;
  final String nombre;
  final String? descripcion;
  final String? codigoAcceso;

  RegisterSubmitted({
    required this.email,
    required this.password,
    required this.nombre,
    this.descripcion,
    this.codigoAcceso,
  });
}
