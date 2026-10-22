import 'package:flutter/material.dart';

import 'package:mocca_go/theme/app_theme.dart';

/// Campo de texto del prototipo (componente "Input"): etiqueta arriba,
/// campo oscuro con borde y texto de ayuda o de error abajo.
///
/// Si [isPassword] es true oculta el texto y muestra el ojo para verlo.
class AppInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final String? helperText;
  final String? errorText;
  final TextInputType keyboardType;
  final int? maxLength;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.helperText,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _obscure = true;

  OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final bottomText = widget.errorText ?? widget.helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          maxLength: widget.maxLength,
          style: const TextStyle(fontSize: 16, color: AppColors.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            counterText: '',
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            enabledBorder: hasError
                ? _border(AppColors.error, 1.5)
                : _border(AppColors.border, 1),
            focusedBorder: hasError
                ? _border(AppColors.error, 1.5)
                : _border(AppColors.primary, 1.5),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
        if (bottomText != null) ...[
          const SizedBox(height: 6),
          Text(
            bottomText,
            style: TextStyle(
              fontSize: 12,
              color: hasError ? AppColors.error : AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
