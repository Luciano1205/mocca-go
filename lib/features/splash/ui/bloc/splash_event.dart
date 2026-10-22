/// Lo que el splash le dice a [SplashBloc].
abstract class SplashEvent {}

/// El splash apareció: hay que revisar si hay sesión.
class SplashStarted extends SplashEvent {}
