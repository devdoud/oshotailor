import 'package:flutter_test/flutter_test.dart';
import 'package:osho/features/personalization/models/user_model.dart';
import 'package:osho/utils/validators/validation.dart';

void main() {
  group('OValidator', () {
    test('e-mail: required, format, long top-level domains accepted', () {
      expect(OValidator.validateEmail(''), 'E-mail requis.');
      expect(OValidator.validateEmail('atelier@osho'), 'E-mail invalide.');
      expect(OValidator.validateEmail('atelier@osho.app'), isNull);
      expect(OValidator.validateEmail('contact@maison.agency'), isNull);
    });

    test('login password is only required, whatever its strength', () {
      expect(OValidator.validateLoginPassword(''), 'Mot de passe requis.');
      expect(OValidator.validateLoginPassword('abc'), isNull);
      expect(OValidator.validateLoginPassword(' with spaces '), isNull);
    });

    test('workshop name: required, 2 to 60 characters', () {
      expect(OValidator.validateWorkshopName('  '), 'Nom requis.');
      expect(OValidator.validateWorkshopName('A'), 'Nom trop court.');
      expect(OValidator.validateWorkshopName('Atelier Koffi'), isNull);
      expect(OValidator.validateWorkshopName('x' * 61), '60 caractères maximum.');
    });

    test('phone: optional, international formats, 8 to 15 digits', () {
      expect(OValidator.validatePhoneNumber(''), isNull);
      expect(OValidator.validatePhoneNumber('', required: true),
          'Téléphone requis.');
      for (final ok in [
        '+229 01 23 45 67',
        '+1 (404) 555-0142',
        '0123456789',
        '+33 6.12.34.56.78',
      ]) {
        expect(OValidator.validatePhoneNumber(ok), isNull, reason: ok);
      }
      for (final bad in ['1234567', '+1234567890123456', '01 23 AB 45 67']) {
        expect(OValidator.validatePhoneNumber(bad), 'Numéro invalide.',
            reason: bad);
      }
    });

    test('messages stay short', () {
      final messages = [
        OValidator.validateEmail(''),
        OValidator.validateEmail('x'),
        OValidator.validateLoginPassword(''),
        OValidator.validatePassword('abc'),
        OValidator.validateWorkshopName(''),
        OValidator.validatePhoneNumber('12'),
      ];
      for (final m in messages) {
        expect(m!.length, lessThanOrEqualTo(30), reason: m);
      }
    });
  });

  group('UserModel.copyWith', () {
    final user = UserModel(
      id: 'u-1',
      email: 'atelier@osho.app',
      firstName: 'Atelier',
      lastName: 'Koffi',
      username: 'koffi',
      phone: '',
      profilePicture: '',
      role: 'tailor',
    );

    test('returns a modified copy and leaves the original untouched', () {
      final copy = user.copyWith(fullName: 'Maison  Ndiaye Couture', phone: '+229 01 02 03 04');
      expect(copy.fullName, 'Maison Ndiaye Couture');
      expect(copy.phone, '+229 01 02 03 04');
      expect(copy.role, 'tailor');
      expect(copy.id, 'u-1');
      expect(user.fullName, 'Atelier Koffi');
      expect(user.phone, '');
    });

    test('a single-word name keeps an empty last name', () {
      final copy = user.copyWith(fullName: 'Ndiaye');
      expect(copy.firstName, 'Ndiaye');
      expect(copy.lastName, '');
      expect(copy.toProfileUpdateJson()['full_name'], 'Ndiaye');
    });
  });
}
