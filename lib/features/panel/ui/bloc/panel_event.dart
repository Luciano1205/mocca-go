/// Lo que el panel le dice a [PanelBloc].
abstract class PanelEvent {}

/// El usuario tocó "Cerrar sesión".
class PanelSignOutRequested extends PanelEvent {}
