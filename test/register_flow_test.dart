import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(App(auth: auth, usuarios: usuarios));
    // El splash dura al menos 1,5 s.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  /// Del login a la pantalla 03 y luego a la opción elegida.
  Future<void> irARegistro(WidgetTester tester, String opcion) async {
    await tester.tap(find.textContaining('Regístrate', findRichText: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcion));
    await tester.pumpAndSettle();
  }

  /// Llena el formulario en orden: nombre, correo, contraseña, descripción
  /// y, si hay, código.
  Future<void> llenar(WidgetTester tester, List<String> valores) async {
    for (var i = 0; i < valores.length; i++) {
      await tester.enterText(find.byType(TextField).at(i), valores[i]);
    }
    await tester.ensureVisible(find.text('Crear cuenta'));
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
  });

  testWidgets('Desde el login se abre el tipo de registro y se vuelve', (
    tester,
  ) async {
    await abrirApp(tester);
    await tester.tap(find.textContaining('Regístrate', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Domiciliario'), findsOneWidget);

    await tester.tap(find.textContaining('Inicia sesión', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Hola de nuevo'), findsOneWidget);
  });

  testWidgets('Registro con campos vacíos muestra los errores', (tester) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Cliente');
    await llenar(tester, []);
    expect(find.text('Escribe tu nombre'), findsOneWidget);
    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe una contraseña'), findsOneWidget);
    expect(auth.signUps, isEmpty);
  });

  testWidgets('Registro valida el correo y la contraseña corta', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Cliente');
    await llenar(tester, ['Laura', 'laura.icesi', '123']);
    expect(find.text('Escribe un correo válido'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener al menos 6 caracteres'),
      findsOneWidget,
    );
    expect(auth.signUps, isEmpty);
  });

  testWidgets('Cliente se registra y vuelve al login con el aviso (02e)', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Cliente');
    await llenar(tester, ['Laura', 'laura@icesi.edu.co', '123456']);

    expect(find.text('¡Cuenta creada exitosamente!'), findsOneWidget);
    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(auth.signUps.single['codigo'], isNull);
    // El caso de uso cierra la sesión al terminar.
    expect(auth.currentUserId(), isNull);
  });

  testWidgets('Correo repetido muestra el error en el aviso rojo', (
    tester,
  ) async {
    auth.passwords['laura@icesi.edu.co'] = '123456';
    await abrirApp(tester);
    await irARegistro(tester, 'Cliente');
    await llenar(tester, ['Laura', 'laura@icesi.edu.co', '123456']);
    expect(find.text('Ya existe una cuenta con ese correo.'), findsOneWidget);
    expect(find.text('Registro de cliente'), findsOneWidget);
  });

  testWidgets('Domiciliario sin código muestra el error del campo', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Domiciliario');
    await llenar(tester, ['Andrés', 'andres@icesi.edu.co', '123456']);
    expect(find.text('Escribe el código de acceso'), findsOneWidget);
    expect(auth.signUps, isEmpty);
  });

  testWidgets('Código inválido sale en el campo y no crea la cuenta (05b)', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Domiciliario');
    await llenar(tester, [
      'Andrés',
      'andres@icesi.edu.co',
      '123456',
      '',
      'MALO-1',
    ]);
    expect(find.text('El código de acceso no es válido.'), findsOneWidget);
    expect(find.text('Registro de domiciliario'), findsOneWidget);
    expect(auth.signUps, isEmpty);
  });

  testWidgets('Domiciliario con código válido se registra y entra a su panel', (
    tester,
  ) async {
    await abrirApp(tester);
    await irARegistro(tester, 'Domiciliario');
    await llenar(tester, [
      'Andrés',
      'andres@icesi.edu.co',
      '123456',
      'Moto',
      'MOCCA-2026',
    ]);
    expect(find.text('¡Cuenta creada exitosamente!'), findsOneWidget);
    expect(auth.signUps.single['codigo'], 'MOCCA-2026');

    // El trigger crearía el perfil; aquí lo simula la prueba.
    usuarios.usuarios['id-andres@icesi.edu.co'] = const Usuario(
      id: 'id-andres@icesi.edu.co',
      nombre: 'Andrés',
      correo: 'andres@icesi.edu.co',
      rol: Rol.proveedor,
    );
    await tester.enterText(find.byType(TextField).at(0), 'andres@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Panel del domiciliario'), findsOneWidget);
  });
}
