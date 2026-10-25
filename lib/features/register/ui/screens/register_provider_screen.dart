import 'package:flutter/material.dart';

import 'package:mocca_go/features/register/ui/widgets/register_form.dart';

/// 05 · Registro de domiciliario. Pide el código de acceso (05b si no es
/// válido).
class RegisterProviderScreen extends StatelessWidget {
  const RegisterProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const RegisterForm(
        title: 'Registro de domiciliario',
        subtitle: 'Ingresa tus datos y el código de acceso.',
        pideCodigo: true,
      ),
    );
  }
}
