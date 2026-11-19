/// Eventos de Editar perfil (13b · cliente, 20b · domiciliario).
abstract class EditarPerfilEvent {}

class GuardarPerfilPressed extends EditarPerfilEvent {
  final String nombre;
  final String descripcion;

  GuardarPerfilPressed({required this.nombre, required this.descripcion});
}
