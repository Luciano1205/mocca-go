/// Producto del menú (tabla `producto`). El precio va en pesos.
class Producto {
  final String id;
  final String categoriaId;
  final String nombre;
  final String? descripcion;
  final int precio;
  final String? imagenUrl;
  final bool disponible;

  const Producto({
    required this.id,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.imagenUrl,
    this.disponible = true,
  });
}
