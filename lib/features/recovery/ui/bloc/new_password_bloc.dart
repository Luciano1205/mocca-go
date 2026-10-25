import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/send_recovery_code_usecase.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_event.dart';
import 'package:mocca_go/features/recovery/ui/bloc/new_password_state.dart';

/// Cambia la contraseña con [ResetPasswordUseCase] y reenvía el código con
/// [SendRecoveryCodeUseCase]. Emite los estados que dibuja la pantalla 02g.
class NewPasswordBloc extends Bloc<NewPasswordEvent, NewPasswordState> {
  final ResetPasswordUseCase _reset;
  final SendRecoveryCodeUseCase _sendCode;

  NewPasswordBloc(this._reset, this._sendCode)
    : super(const NewPasswordState()) {
    on<NewPasswordSubmitted>(_onSubmitted);
    on<NewPasswordResendRequested>(_onResendRequested);
  }

  Future<void> _onSubmitted(
    NewPasswordSubmitted event,
    Emitter<NewPasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NewPasswordStatus.loading,
        resendStatus: NewPasswordStatus.initial,
      ),
    );
    try {
      await _reset(
        email: event.email,
        code: event.code,
        newPassword: event.newPassword,
      );
      emit(state.copyWith(status: NewPasswordStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: NewPasswordStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onResendRequested(
    NewPasswordResendRequested event,
    Emitter<NewPasswordState> emit,
  ) async {
    emit(
      state.copyWith(
        status: NewPasswordStatus.initial,
        resendStatus: NewPasswordStatus.loading,
      ),
    );
    try {
      await _sendCode(event.email);
      emit(state.copyWith(resendStatus: NewPasswordStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          resendStatus: NewPasswordStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
