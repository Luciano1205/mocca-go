import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Foto cuadrada del producto. Sin foto, o si no carga, muestra una taza.
class ProductoImagen extends StatelessWidget {
  final String? url;
  final double size;
  final bool apagada;

  const ProductoImagen({super.key, this.url, this.size = 64, this.apagada = false});

  @override
  Widget build(BuildContext context) {
    final respaldo = Container(
      width: size,
      height: size,
      color: AppColors.surface2,
      child: Icon(Icons.coffee_outlined, color: AppColors.textMuted, size: size * 0.45),
    );
    final imagen = url == null
        ? respaldo
        : Image.network(
            url!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => respaldo,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      // Agotado: la foto en gris, como en el prototipo.
      child: apagada
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child: Opacity(opacity: 0.5, child: imagen),
            )
          : imagen,
    );
  }
}
