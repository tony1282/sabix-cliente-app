import 'package:flutter_test/flutter_test.dart';
import 'package:sabix_cliente_app/core/utils/validators.dart';

void main() {
  final validators = <String, String? Function(String?)>{
    'Obligatorio': Validators.required,
    'Correo': Validators.validateEmail,
    'Contraseña': Validators.validatePassword,
    'Teléfono': Validators.validatePhone,
    'Nombre': Validators.validateName,
    'Usuario': Validators.validateUsername,
  };
  for (final entry in validators.entries) {
    for (final value in <String?>[null, '']) {
      test('${entry.key} rechaza el valor vacío "$value"', () {
        expect(entry.value(value), 'Este campo es requerido');
      });
    }
  }
  test('un campo requerido rechaza espacios y acepta contenido', () {
    expect(Validators.required('   '), 'Este campo es requerido');
    expect(Validators.required(' Cliente '), isNull);
  });
  for (final value in [
    'cliente',
    'cliente@',
    '@example.com',
    'a b@example.com',
  ]) {
    test('rechaza el correo inválido "$value"', () {
      expect(Validators.validateEmail(value), 'Correo inválido');
    });
  }
  test('acepta un correo válido con espacios externos', () {
    expect(Validators.validateEmail(' cliente@example.com '), isNull);
  });
  test('contraseña: rechaza cinco caracteres y acepta seis o más', () {
    expect(Validators.validatePassword('abc12'), 'Mínimo 6 caracteres');
    expect(Validators.validatePassword('abc123'), isNull);
    expect(Validators.validatePassword('cliente123'), isNull);
  });
  test('confirmación: exige contenido y coincidencia exacta', () {
    expect(
      Validators.validateConfirmPassword(null, 'abc123'),
      'Este campo es requerido',
    );
    expect(
      Validators.validateConfirmPassword('', 'abc123'),
      'Este campo es requerido',
    );
    expect(
      Validators.validateConfirmPassword('abc124', 'abc123'),
      'Las contraseñas no coinciden',
    );
    expect(Validators.validateConfirmPassword('abc123', 'abc123'), isNull);
  });
  for (final value in ['551234567', '55123456789', '551234567a']) {
    test('rechaza el teléfono inválido "$value"', () {
      expect(Validators.validatePhone(value), 'Teléfono inválido (10 dígitos)');
    });
  }
  test('acepta diez dígitos con espacios externos', () {
    expect(Validators.validatePhone(' 5512345678 '), isNull);
  });
  for (final name in ['Nombre', 'Usuario']) {
    test('$name exige tres caracteres sin contar espacios externos', () {
      final validate = validators[name]!;
      expect(validate('   '), 'Este campo es requerido');
      expect(validate(' ab '), 'Mínimo 3 caracteres');
      expect(validate(' Ana '), isNull);
    });
  }
}
