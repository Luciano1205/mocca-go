import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mocca_go/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_event.dart';
import 'package:mocca_go/features/splash/ui/bloc/splash_state.dart';

/// Revisa si hay sesión. Espera al menos [minDuration] para que se alcance
/// a ver la marca (en el prototipo el splash dura 1,5 s).
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetSessionUseCase _getSession;
  final Duration minDuration;

  SplashBloc(
    this._getSession, {
    this.minDuration = const Duration(milliseconds: 1500),
  }) : super(const SplashState()) {
    on<SplashStarted>(_onStarted);
  }

  Future<void> _onStarted(SplashStarted event, Emitter<SplashState> emit) async {
    final minWait = Future<void>.delayed(minDuration);
    final usuario = await _getSession();
    await minWait;
    if (usuario == null) {
      emit(state.copyWith(status: SplashStatus.unauthenticated));
    } else {
      emit(state.copyWith(status: SplashStatus.authenticated, usuario: usuario));
    }
  }
}
