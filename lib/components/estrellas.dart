import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Componente "Rating" del prototipo: 5 estrellas que se tocan para elegir
/// de 1 a 5. Sin [onChanged] solo muestra el valor.
class Estrellas extends StatelessWidget {
  final int valor;
  final ValueChanged<int>? onChanged;
  final double size;

  const Estrellas({super.key, required this.valor, this.onChanged, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            key: Key('estrella-$i'),
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                i <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
                size: size,
                color: i <= valor ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
