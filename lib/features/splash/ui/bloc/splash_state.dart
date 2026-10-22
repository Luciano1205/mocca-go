import 'package:mocca_go/features/auth/domain/entities/usuario.dart';

/// En qué momento está el splash.
enum SplashStatus { checking, unauthenticated, authenticated }

/// Estado único: el momento es [status] y [copyWith] cambia solo lo que
/// se le pasa.
class SplashState {
  final SplashStatus status;
  final Usuario? usuario;

  const SplashState({this.status = SplashStatus.checking, this.usuario});

  SplashState copyWith({SplashStatus? status, Usuario? usuario}) {
    return SplashState(
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
    );
  }
}
