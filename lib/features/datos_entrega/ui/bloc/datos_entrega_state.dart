import 'package:mocca_go/features/catalogo/domain/entities/entidad_pago.dart';
import 'package:mocca_go/features/catalogo/domain/entities/zona.dart';
import 'package:mocca_go/features/pedidos/domain/entities/pedido.dart';

/// [loading] carga zonas y entidades; [ready] ya se puede llenar;
/// [enviando] espera a Supabase; [enviado] tiene el [pedido] creado.
enum DatosEntregaStatus { initial, loading, ready, enviando, enviado, failure }

class DatosEntregaState {
  final DatosEntregaStatus status;
  final List<Zona> zonas;
  final List<EntidadPago> entidades;
  final Pedido? pedido;
  final String? errorMessage;

  const DatosEntregaState({
    this.status = DatosEntregaStatus.initial,
    this.zonas = const [],
    this.entidades = const [],
    this.pedido,
    this.errorMessage,
  });

  /// [errorMessage] no se arrastra: si no se pasa, queda vacío.
  DatosEntregaState copyWith({
    DatosEntregaStatus? status,
    List<Zona>? zonas,
    List<EntidadPago>? entidades,
    Pedido? pedido,
    String? errorMessage,
  }) {
    return DatosEntregaState(
      status: status ?? this.status,
      zonas: zonas ?? this.zonas,
      entidades: entidades ?? this.entidades,
      pedido: pedido ?? this.pedido,
      errorMessage: errorMessage,
    );
  }
}
