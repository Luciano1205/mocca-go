import 'package:flutter_test/flutter_test.dart';

import 'package:mocca_go/features/auth/domain/entities/usuario.dart';
import 'package:mocca_go/features/auth/domain/errors/auth_failure.dart';
import 'package:mocca_go/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/send_recovery_code_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:mocca_go/features/auth/domain/usecases/sign_up_usecase.dart';

import 'fakes/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeUsuarioRepository usuarios;

  setUp(() {
    auth = FakeAuthRepository();
    usuarios = FakeUsuarioRepository();
  });

  void crearPerfil(String email, Rol rol) {
    final id = auth.ids[email]!;
    usuarios.usuarios[id] = Usuario(id: id, nombre: 'Laura', correo: email, rol: rol);
  }

  test('Registro de cliente: crea la cuenta y deja la sesión cerrada', () async {
    await SignUpUseCase(auth)(email: 'laura@icesi.edu.co', password: '123456', nombre: 'Laura');
    expect(auth.signUps.single['codigo'], isNull);
    expect(auth.currentUserId(), isNull);
  });

  test('Registro de domiciliario con código inválido no crea la cuenta', () async {
    await expectLater(
      SignUpUseCase(auth)(
        email: 'andres@icesi.edu.co',
        password: '123456',
        nombre: 'Andrés',
        codigoAcceso: 'OTRO',
      ),
      throwsA(isA<AuthFailure>()),
    );
    expect(auth.signUps, isEmpty);
  });

  test('Registro de domiciliario con código válido envía el código', () async {
    await SignUpUseCase(auth)(
      email: 'andres@icesi.edu.co',
      password: '123456',
      nombre: 'Andrés',
      codigoAcceso: 'mocca-2026',
    );
    expect(auth.signUps.single['codigo'], 'mocca-2026');
  });

  test('Login devuelve el perfil con su rol', () async {
    await SignUpUseCase(auth)(email: 'a@icesi.edu.co', password: '123456', nombre: 'A');
    crearPerfil('a@icesi.edu.co', Rol.proveedor);
    final usuario = await SignInUseCase(auth, usuarios)(email: 'a@icesi.edu.co', password: '123456');
    expect(usuario.rol, Rol.proveedor);
  });

  test('Login sin perfil cierra la sesión y falla', () async {
    await SignUpUseCase(auth)(email: 'a@icesi.edu.co', password: '123456', nombre: 'A');
    await expectLater(
      SignInUseCase(auth, usuarios)(email: 'a@icesi.edu.co', password: '123456'),
      throwsA(isA<AuthFailure>()),
    );
    expect(auth.currentUserId(), isNull);
  });

  test('Splash: sin sesión devuelve null y con sesión el perfil', () async {
    expect(await GetSessionUseCase(auth, usuarios)(), isNull);
    await SignUpUseCase(auth)(email: 'a@icesi.edu.co', password: '123456', nombre: 'A');
    crearPerfil('a@icesi.edu.co', Rol.cliente);
    await SignInUseCase(auth, usuarios)(email: 'a@icesi.edu.co', password: '123456');
    expect((await GetSessionUseCase(auth, usuarios)())?.rol, Rol.cliente);
  });

  test('Recuperar contraseña: código correcto cambia la contraseña', () async {
    await SignUpUseCase(auth)(email: 'a@icesi.edu.co', password: '123456', nombre: 'A');
    await SendRecoveryCodeUseCase(auth)('a@icesi.edu.co');
    await ResetPasswordUseCase(auth)(email: 'a@icesi.edu.co', code: '123456', newPassword: 'nueva123');
    expect(auth.passwords['a@icesi.edu.co'], 'nueva123');
    expect(auth.currentUserId(), isNull);
  });

  test('Recuperar contraseña: código incorrecto falla', () async {
    await SignUpUseCase(auth)(email: 'a@icesi.edu.co', password: '123456', nombre: 'A');
    await SendRecoveryCodeUseCase(auth)('a@icesi.edu.co');
    await expectLater(
      ResetPasswordUseCase(auth)(email: 'a@icesi.edu.co', code: '000000', newPassword: 'nueva123'),
      throwsA(isA<AuthFailure>()),
    );
  });
}
