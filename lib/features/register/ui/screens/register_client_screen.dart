import 'package:flutter/material.dart';

import 'package:mocca_go/features/register/ui/widgets/register_form.dart';

/// 04 · Registro de cliente.
class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const RegisterForm(
        title: 'Registro de cliente',
        subtitle: 'Crea tu cuenta para pedir tu café.',
      ),
    );
  }
}
