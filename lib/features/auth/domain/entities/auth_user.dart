/// Lo que Supabase Auth devuelve: la identidad de la cuenta.
///
/// La contraseña no está aquí: solo viaja hacia Auth.
class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});
}
