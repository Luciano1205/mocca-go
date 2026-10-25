import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/usecases/send_recovery_code_usecase.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_event.dart';
import 'package:mocca_go/features/recovery/ui/bloc/recover_state.dart';

/// Pide a [SendRecoveryCodeUseCase] que envíe el código de 6 dígitos y
/// emite los estados que dibuja la pantalla 02f.
class RecoverBloc extends Bloc<RecoverEvent, RecoverState> {
  final SendRecoveryCodeUseCase _sendCode;

  RecoverBloc(this._sendCode) : super(const RecoverState()) {
    on<RecoverSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RecoverSubmitted event,
    Emitter<RecoverState> emit,
  ) async {
    emit(state.copyWith(status: RecoverStatus.loading));
    try {
      await _sendCode(event.email);
      emit(state.copyWith(status: RecoverStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: RecoverStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
