import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:mocca_go/features/register/ui/bloc/register_event.dart';
import 'package:mocca_go/features/register/ui/bloc/register_state.dart';

/// Recibe el formulario de registro, crea la cuenta con [SignUpUseCase] y
/// emite los estados que dibujan las pantallas 04 y 05.
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase _signUp;

  RegisterBloc(this._signUp) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await _signUp(
        email: event.email,
        password: event.password,
        nombre: event.nombre,
        descripcion: event.descripcion,
        codigoAcceso: event.codigoAcceso,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
