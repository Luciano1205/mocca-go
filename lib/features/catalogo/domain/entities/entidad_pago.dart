/// Cuenta a la que se transfiere (tabla `entidad_pago`): Nequi, Bancolombia...
class EntidadPago {
  final String id;
  final String nombre;
  final String datoDestino;
  final String titular;

  const EntidadPago({
    required this.id,
    required this.nombre,
    required this.datoDestino,
    required this.titular,
  });
}
