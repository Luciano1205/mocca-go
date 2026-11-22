import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

enum EditarPerfilStatus { initial, guardando, guardado, failure }

class EditarPerfilState {
  final EditarPerfilStatus status;

  /// El perfil como está en la base (el nuevo después de guardar).
  final Usuario usuario;
  final String? errorMessage;

  const EditarPerfilState({
    this.status = EditarPerfilStatus.initial,
    required this.usuario,
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  EditarPerfilState copyWith({
    EditarPerfilStatus? status,
    Usuario? usuario,
    String? errorMessage,
  }) {
    return EditarPerfilState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      errorMessage: errorMessage,
    );
  }
}
