import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/crypto_helper.dart';

void main() {
  group('Crypto Edge Cases Tests', () {
    late AESCipher cipher;

    setUp(() {
      cipher = AESCipher(Uint8List.fromList('1234567890123456'.codeUnits));
    });

    test('Encrypt with empty data', () {
      final emptyData = Uint8List(0);
      final encrypted = cipher.encrypt(emptyData, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Decrypt with empty data', () {
      final emptyData = Uint8List(0);
      final encrypted = cipher.encrypt(emptyData, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(emptyData));
    });

    test('Encrypt with single byte', () {
      final singleByte = Uint8List.fromList([0x42]);
      final encrypted = cipher.encrypt(singleByte, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Decrypt with single byte', () {
      final singleByte = Uint8List.fromList([0x42]);
      final encrypted = cipher.encrypt(singleByte, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(singleByte));
    });

    test('Encrypt with exactly 16 bytes', () {
      final data16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted = cipher.encrypt(data16, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Decrypt with exactly 16 bytes', () {
      final data16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted = cipher.encrypt(data16, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(data16));
    });

    test('Encrypt with exactly 15 bytes', () {
      final data15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted = cipher.encrypt(data15, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Decrypt with exactly 15 bytes', () {
      final data15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted = cipher.encrypt(data15, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(data15));
    });

    test('Encrypt with exactly 17 bytes', () {
      final data17 = Uint8List.fromList('12345678901234567'.codeUnits);
      final encrypted = cipher.encrypt(data17, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Decrypt with exactly 17 bytes', () {
      final data17 = Uint8List.fromList('12345678901234567'.codeUnits);
      final encrypted = cipher.encrypt(data17, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(data17));
    });

    test('Encrypt with maximum padding (15 bytes)', () {
      final data15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted = cipher.encrypt(data15, pad: true);
      expect(encrypted, isNotNull);
      expect(
        encrypted.length,
        greaterThanOrEqualTo(16),
      ); // Should be padded to at least 16 bytes
    });

    test('Decrypt with maximum padding', () {
      final data15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted = cipher.encrypt(data15, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(data15));
    });

    test('Encrypt with useBase64: true', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, useBase64: true, pad: true);
      expect(encrypted, isNotNull);
      expect(
        encrypted,
        isA<Uint8List>(),
      ); // The method returns Uint8List, not String
    });

    test('Decrypt with useBase64: true', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, useBase64: true, pad: true);
      final decrypted = cipher.decrypt(
        encrypted,
        useBase64: true,
        verifyPadding: true,
      );
      expect(decrypted, equals(testData));
    });

    test('Encrypt with useBase64: false', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, useBase64: false, pad: true);
      expect(encrypted, isNotNull);
      expect(encrypted, isA<Uint8List>());
    });

    test('Decrypt with useBase64: false', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, useBase64: false, pad: true);
      final decrypted = cipher.decrypt(
        encrypted,
        useBase64: false,
        verifyPadding: true,
      );
      expect(decrypted, equals(testData));
    });

    test('Encrypt with pad: false and 16-byte data', () {
      final data16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted = cipher.encrypt(data16, pad: false);
      expect(encrypted, isNotNull);
      expect(
        encrypted.length,
        greaterThanOrEqualTo(16),
      ); // May include additional data
    });

    test('Decrypt with pad: false and 16-byte data', () {
      final data16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted = cipher.encrypt(data16, pad: false);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: false);
      expect(decrypted, equals(data16));
    });

    test('GCM encryption with empty data', () {
      final emptyData = Uint8List(0);
      final iv = Uint8List.fromList('123456789012'.codeUnits);
      final header = Uint8List.fromList('header'.codeUnits);

      final encrypted = cipher.encryptGCM(emptyData, iv: iv, header: header);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('GCM encryption with single byte', () {
      final singleByte = Uint8List.fromList([0x42]);
      final iv = Uint8List.fromList('123456789012'.codeUnits);
      final header = Uint8List.fromList('header'.codeUnits);

      final encrypted = cipher.encryptGCM(singleByte, iv: iv, header: header);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('GCM encryption with 16-byte data', () {
      final data16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final iv = Uint8List.fromList('123456789012'.codeUnits);
      final header = Uint8List.fromList('header'.codeUnits);

      final encrypted = cipher.encryptGCM(data16, iv: iv, header: header);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('GCM encryption with different IV sizes', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final header = Uint8List.fromList('header'.codeUnits);

      // Test with 12-byte IV
      final iv12 = Uint8List.fromList('123456789012'.codeUnits);
      final encrypted12 = cipher.encryptGCM(testData, iv: iv12, header: header);
      expect(encrypted12, isNotNull);

      // Test with 16-byte IV
      final iv16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted16 = cipher.encryptGCM(testData, iv: iv16, header: header);
      expect(encrypted16, isNotNull);
    });

    test('GCM encryption with empty header', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final iv = Uint8List.fromList('123456789012'.codeUnits);
      final emptyHeader = Uint8List(0);

      final encrypted = cipher.encryptGCM(
        testData,
        iv: iv,
        header: emptyHeader,
      );
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('GCM encryption with null header', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final iv = Uint8List.fromList('123456789012'.codeUnits);

      final encrypted = cipher.encryptGCM(testData, iv: iv, header: null);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));
    });

    test('Error handling for invalid key length in constructor', () {
      expect(() {
        AESCipher(Uint8List(8)); // Invalid key length
      }, throwsA(isA<ArgumentError>()));
    });

    test('Error handling for null key in constructor', () {
      expect(() {
        AESCipher(Uint8List(0)); // Empty key
      }, throwsA(isA<ArgumentError>()));
    });

    test('Error handling for too long key in constructor', () {
      expect(() {
        AESCipher(Uint8List(32)); // Too long key
      }, throwsA(isA<ArgumentError>()));
    });
  });
}
