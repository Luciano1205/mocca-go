import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/main.dart';

import 'fakes/fake_repositories.dart';

/// Simula el límite de Supabase: solo deja enviar el código una vez.
class _LimitedAuthRepository extends FakeAuthRepository {
  int envios = 0;

  @override
  Future<void> sendRecoveryCode(String email) async {
    envios++;
    if (envios > 1) {
      throw const AuthFailure(
        'Espera un momento antes de volver a intentarlo.',
      );
    }
    await super.sendRecoveryCode(email);
  }
}

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;
  const email = 'laura@icesi.edu.co';

  void crearCuenta() {
    auth.passwords[email] = '123456';
    auth.ids[email] = 'id-$email';
    usuarios.usuarios['id-$email'] = const Usuario(
      id: 'id-$email',
      nombre: 'Laura',
      correo: email,
      rol: Rol.cliente,
    );
  }

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(App(auth: auth, usuarios: usuarios));
    // El splash dura al menos 1,5 s.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester tester, String texto) async {
    final finder = find.text(texto);
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// Del login a 02f y, con el correo, a 02g.
  Future<void> irANuevaContrasena(WidgetTester tester) async {
    await tocar(tester, '¿Olvidaste tu contraseña?');
    await tester.enterText(find.byType(TextField), email);
    await tocar(tester, 'Enviar código');
  }

  Future<void> cambiar(
    WidgetTester tester,
    String code,
    String pass,
    String confirm,
  ) async {
    await tester.enterText(find.byType(TextField).at(0), code);
    await tester.enterText(find.byType(TextField).at(1), pass);
    await tester.enterText(find.byType(TextField).at(2), confirm);
    await tocar(tester, 'Cambiar contraseña');
  }

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
    crearCuenta();
  });

  testWidgets('02f valida el correo antes de enviar', (tester) async {
    await abrirApp(tester);
    await tocar(tester, '¿Olvidaste tu contraseña?');
    await tocar(tester, 'Enviar código');
    expect(find.text('Escribe tu correo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'laura.icesi');
    await tocar(tester, 'Enviar código');
    expect(find.text('Escribe un correo válido'), findsOneWidget);
    expect(auth.lastRecoveryEmail, isNull);
  });

  testWidgets('02f vuelve al login con "Inicia sesión"', (tester) async {
    await abrirApp(tester);
    await tocar(tester, '¿Olvidaste tu contraseña?');
    await tester.tap(find.textContaining('Inicia sesión', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Hola de nuevo'), findsOneWidget);
  });

  testWidgets('02f envía el código y abre 02g con el correo', (tester) async {
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    expect(auth.lastRecoveryEmail, email);
    expect(find.text('Nueva contraseña'), findsWidgets);
    expect(find.textContaining(email, findRichText: true), findsOneWidget);
  });

  testWidgets('02g valida el código y que las contraseñas coincidan', (
    tester,
  ) async {
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    await cambiar(tester, '123', 'nueva123', 'otra123');
    expect(find.text('Escribe el código de 6 dígitos'), findsOneWidget);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
  });

  testWidgets('02g con código malo muestra el error', (tester) async {
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    await cambiar(tester, '999999', 'nueva123', 'nueva123');
    expect(find.text('El código es incorrecto o ya venció.'), findsOneWidget);
    expect(auth.passwords[email], '123456');
  });

  testWidgets('Reenviar el código muestra el aviso verde', (tester) async {
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    await tester.tap(find.textContaining('Reenviar', findRichText: true));
    await tester.pumpAndSettle();
    expect(find.text('Te enviamos un nuevo código.'), findsOneWidget);
  });

  testWidgets('Reenviar antes de tiempo muestra el aviso de espera', (
    tester,
  ) async {
    auth = _LimitedAuthRepository();
    crearCuenta();
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    await tester.tap(find.textContaining('Reenviar', findRichText: true));
    await tester.pumpAndSettle();
    expect(
      find.text('Espera un momento antes de volver a intentarlo.'),
      findsOneWidget,
    );
  });

  testWidgets('Cambia la contraseña, vuelve al login (02h) y entra con ella', (
    tester,
  ) async {
    await abrirApp(tester);
    await irANuevaContrasena(tester);
    await cambiar(tester, '123456', 'nueva123', 'nueva123');

    expect(find.text('¡Contraseña actualizada!'), findsOneWidget);
    expect(auth.passwords[email], 'nueva123');
    expect(auth.currentUserId(), isNull);

    await tester.enterText(find.byType(TextField).at(0), email);
    await tester.enterText(find.byType(TextField).at(1), 'nueva123');
    await tocar(tester, 'Iniciar sesión');
    expect(find.text('Panel del cliente'), findsOneWidget);
  });
}
