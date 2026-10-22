/// En qué momento está el panel.
enum PanelStatus { initial, signingOut, signedOut, failure }

/// Estado único con [copyWith].
class PanelState {
  final PanelStatus status;
  final String? errorMessage;

  const PanelState({this.status = PanelStatus.initial, this.errorMessage});

  PanelState copyWith({PanelStatus? status, String? errorMessage}) {
    return PanelState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
