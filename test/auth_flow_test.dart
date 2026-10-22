import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;

  /// Crea una cuenta con su perfil, como lo haría el trigger.
  void crearCuenta(String email, Rol rol, {String nombre = 'Laura'}) {
    auth.passwords[email] = '123456';
    auth.ids[email] = 'id-$email';
    usuarios.usuarios['id-$email'] =
        Usuario(id: 'id-$email', nombre: nombre, correo: email, rol: rol);
  }

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(App(auth: auth, usuarios: usuarios));
    // El splash dura al menos 1,5 s.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  Future<void> iniciarSesion(WidgetTester tester, String email, String pass) async {
    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), pass);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();
  }

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
  });

  testWidgets('Sin sesión, el splash lleva al login', (tester) async {
    await abrirApp(tester);
    expect(find.text('Hola de nuevo'), findsOneWidget);
  });

  testWidgets('Con sesión, el splash lleva al panel del rol', (tester) async {
    crearCuenta('andres@icesi.edu.co', Rol.proveedor, nombre: 'Andrés');
    auth.sessionUserId = 'id-andres@icesi.edu.co';
    await abrirApp(tester);
    expect(find.text('Panel del domiciliario'), findsOneWidget);
  });

  testWidgets('Login con campos vacíos muestra los errores', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
  });

  testWidgets('Login con contraseña incorrecta muestra el error', (tester) async {
    crearCuenta('laura@icesi.edu.co', Rol.cliente);
    await abrirApp(tester);
    await iniciarSesion(tester, 'laura@icesi.edu.co', 'mala');
    expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
  });

  testWidgets('Cliente entra a su panel y cierra sesión', (tester) async {
    crearCuenta('laura@icesi.edu.co', Rol.cliente);
    await abrirApp(tester);
    await iniciarSesion(tester, 'laura@icesi.edu.co', '123456');
    expect(find.text('Panel del cliente'), findsOneWidget);
    expect(find.text('Hola, Laura'), findsOneWidget);

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(auth.currentUserId(), isNull);
  });

  testWidgets('Domiciliario entra al panel del domiciliario', (tester) async {
    crearCuenta('andres@icesi.edu.co', Rol.proveedor, nombre: 'Andrés');
    await abrirApp(tester);
    await iniciarSesion(tester, 'andres@icesi.edu.co', '123456');
    expect(find.text('Panel del domiciliario'), findsOneWidget);
  });
}
