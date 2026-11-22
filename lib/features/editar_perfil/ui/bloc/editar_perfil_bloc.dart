import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/usecases/actualizar_perfil_usecase.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_event.dart';
import 'package:mocca_go/features/editar_perfil/ui/bloc/editar_perfil_state.dart';

/// Guarda nombre y descripción. Rol y calificación no se editan.
class EditarPerfilBloc extends Bloc<EditarPerfilEvent, EditarPerfilState> {
  final ActualizarPerfilUseCase _actualizar;

  EditarPerfilBloc(this._actualizar, Usuario usuario)
    : super(EditarPerfilState(usuario: usuario)) {
    on<GuardarPerfilPressed>(_onGuardar);
  }

  Future<void> _onGuardar(
    GuardarPerfilPressed event,
    Emitter<EditarPerfilState> emit,
  ) async {
    emit(state.copyWith(status: EditarPerfilStatus.guardando));
    try {
      final usuario = await _actualizar(
        state.usuario,
        nombre: event.nombre,
        descripcion: event.descripcion,
      );
      emit(state.copyWith(status: EditarPerfilStatus.guardado, usuario: usuario));
    } on Exception catch (e) {
      emit(state.copyWith(status: EditarPerfilStatus.failure, errorMessage: '$e'));
    }
  }
}
