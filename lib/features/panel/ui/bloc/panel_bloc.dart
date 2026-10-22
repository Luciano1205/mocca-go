import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_event.dart';
import 'package:mocca_go/features/panel/ui/bloc/panel_state.dart';

/// Cierra la sesión con [SignOutUseCase].
class PanelBloc extends Bloc<PanelEvent, PanelState> {
  final SignOutUseCase _signOut;

  PanelBloc(this._signOut) : super(const PanelState()) {
    on<PanelSignOutRequested>(_onSignOut);
  }

  Future<void> _onSignOut(
    PanelSignOutRequested event,
    Emitter<PanelState> emit,
  ) async {
    emit(state.copyWith(status: PanelStatus.signingOut));
    try {
      await _signOut();
      emit(state.copyWith(status: PanelStatus.signedOut));
    } on Exception catch (e) {
      emit(state.copyWith(status: PanelStatus.failure, errorMessage: '$e'));
    }
  }
}
