/// En qué momento está el envío del código.
enum RecoverStatus { initial, loading, success, failure }

/// Estado único: el momento es [status] y [copyWith] cambia solo lo que
/// se le pasa.
class RecoverState {
  final RecoverStatus status;
  final String? errorMessage;

  const RecoverState({this.status = RecoverStatus.initial, this.errorMessage});

  RecoverState copyWith({RecoverStatus? status, String? errorMessage}) {
    return RecoverState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
