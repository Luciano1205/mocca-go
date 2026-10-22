import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/components/app_input.dart';
import 'package:mocca_go/components/primary_button.dart';
import 'package:mocca_go/theme/app_theme.dart';

void main() {
  testWidgets('El botón muestra su texto y responde al toque', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: PrimaryButton(label: 'Iniciar sesión', onPressed: () => taps++),
        ),
      ),
    );
    await tester.tap(find.text('Iniciar sesión'));
    expect(taps, 1);
  });

  testWidgets('El campo de contraseña permite mostrar el texto', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: AppInput(
            label: 'Contraseña',
            hint: 'Tu contraseña',
            controller: controller,
            isPassword: true,
            errorText: 'Correo o contraseña incorrectos.',
          ),
        ),
      ),
    );
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    controller.dispose();
  });
}
