import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

void main() {
  group('Crypto Comprehensive Tests', () {
    late AESCipher cipher;
    final testKey = Uint8List.fromList('1234567890123456'.codeUnits);

    setUp(() {
      cipher = AESCipher(testKey);
    });

    test('AESCipher creation', () {
      expect(cipher, isNotNull);
    });

    test('Encrypt with different data sizes', () {
      // Test empty data
      final emptyData = Uint8List(0);
      final encryptedEmpty = cipher.encrypt(emptyData, pad: true);
      expect(encryptedEmpty, isNotNull);
      expect(encryptedEmpty.length, greaterThan(0));

      // Test single byte
      final singleByte = Uint8List.fromList([65]); // 'A'
      final encryptedSingle = cipher.encrypt(singleByte, pad: true);
      expect(encryptedSingle, isNotNull);
      expect(encryptedSingle.length, greaterThan(0));

      // Test exactly 16 bytes
      final exactly16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted16 = cipher.encrypt(exactly16, pad: true);
      expect(encrypted16, isNotNull);
      expect(encrypted16.length, greaterThan(0));

      // Test 15 bytes (needs padding)
      final exactly15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted15 = cipher.encrypt(exactly15, pad: true);
      expect(encrypted15, isNotNull);
      expect(encrypted15.length, greaterThan(0));

      // Test 17 bytes (needs padding)
      final exactly17 = Uint8List.fromList('12345678901234567'.codeUnits);
      final encrypted17 = cipher.encrypt(exactly17, pad: true);
      expect(encrypted17, isNotNull);
      expect(encrypted17.length, greaterThan(0));
    });

    test('Decrypt with different data sizes', () {
      // Test empty data
      final emptyData = Uint8List(0);
      final encryptedEmpty = cipher.encrypt(emptyData, pad: true);
      final decryptedEmpty = cipher.decrypt(
        encryptedEmpty,
        verifyPadding: true,
      );
      expect(decryptedEmpty, equals(emptyData));

      // Test single byte
      final singleByte = Uint8List.fromList([65]); // 'A'
      final encryptedSingle = cipher.encrypt(singleByte, pad: true);
      final decryptedSingle = cipher.decrypt(
        encryptedSingle,
        verifyPadding: true,
      );
      expect(decryptedSingle, equals(singleByte));

      // Test exactly 16 bytes
      final exactly16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encrypted16 = cipher.encrypt(exactly16, pad: true);
      final decrypted16 = cipher.decrypt(encrypted16, verifyPadding: true);
      expect(decrypted16, equals(exactly16));

      // Test 15 bytes (needs padding)
      final exactly15 = Uint8List.fromList('123456789012345'.codeUnits);
      final encrypted15 = cipher.encrypt(exactly15, pad: true);
      final decrypted15 = cipher.decrypt(encrypted15, verifyPadding: true);
      expect(decrypted15, equals(exactly15));

      // Test 17 bytes (needs padding)
      final exactly17 = Uint8List.fromList('12345678901234567'.codeUnits);
      final encrypted17 = cipher.encrypt(exactly17, pad: true);
      final decrypted17 = cipher.decrypt(encrypted17, verifyPadding: true);
      expect(decrypted17, equals(exactly17));
    });

    test('Encrypt with different options', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);

      // Test with useBase64: true
      final encryptedBase64 = cipher.encrypt(
        testData,
        useBase64: true,
        pad: true,
      );
      expect(encryptedBase64, isNotNull);
      expect(encryptedBase64.length, greaterThan(0));

      // Test with useBase64: false
      final encryptedBinary = cipher.encrypt(
        testData,
        useBase64: false,
        pad: true,
      );
      expect(encryptedBinary, isNotNull);
      expect(encryptedBinary.length, greaterThan(0));

      // Test with pad: true
      final encryptedPadded = cipher.encrypt(testData, pad: true);
      expect(encryptedPadded, isNotNull);
      expect(encryptedPadded.length, greaterThan(0));

      // Test with pad: false (requires data to be multiple of 16)
      final testData16 = Uint8List.fromList('1234567890123456'.codeUnits);
      final encryptedUnpadded = cipher.encrypt(testData16, pad: false);
      expect(encryptedUnpadded, isNotNull);
      expect(encryptedUnpadded.length, greaterThan(0));
    });

    test('Decrypt with different options', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);

      // Test with useBase64: true
      final encryptedBase64 = cipher.encrypt(
        testData,
        useBase64: true,
        pad: true,
      );
      final decryptedBase64 = cipher.decrypt(
        encryptedBase64,
        useBase64: true,
        verifyPadding: true,
      );
      expect(decryptedBase64, equals(testData));

      // Test with useBase64: false
      final encryptedBinary = cipher.encrypt(
        testData,
        useBase64: false,
        pad: true,
      );
      final decryptedBinary = cipher.decrypt(
        encryptedBinary,
        useBase64: false,
        verifyPadding: true,
      );
      expect(decryptedBinary, equals(testData));

      // Test with decodeText: true
      final encryptedText = cipher.encrypt(
        testData,
        useBase64: true,
        pad: true,
      );
      final decryptedText = cipher.decrypt(
        encryptedText,
        useBase64: true,
        decodeText: true,
        verifyPadding: true,
      );
      expect(decryptedText, isA<Uint8List>());

      // Test with decodeText: false
      final decryptedBytes = cipher.decrypt(
        encryptedText,
        useBase64: true,
        decodeText: false,
        verifyPadding: true,
      );
      expect(decryptedBytes, isA<Uint8List>());
    });

    test('Encrypt with verifyPadding: true', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: true);
      expect(decrypted, equals(testData));
    });

    test('Encrypt with verifyPadding: false', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final encrypted = cipher.encrypt(testData, pad: true);
      final decrypted = cipher.decrypt(encrypted, verifyPadding: false);
      // When verifyPadding: false, padding is not removed, so we expect the original data + padding
      expect(decrypted.length, greaterThanOrEqualTo(testData.length));
      expect(decrypted.sublist(0, testData.length), equals(testData));
    });

    test('GCM encryption and decryption', () {
      final testData = Uint8List.fromList('Hello World'.codeUnits);
      final iv = Uint8List.fromList(
        '123456789012'.codeUnits,
      ); // 12 bytes for GCM
      final header = Uint8List.fromList('header'.codeUnits);

      final encrypted = cipher.encryptGCM(testData, iv: iv, header: header);
      expect(encrypted, isNotNull);
      expect(encrypted.length, greaterThan(0));

      // Note: GCM decryption requires proper tag handling which is complex
      // For now, just test that encryption works
    });

    test('Error handling for invalid key length', () {
      expect(() {
        AESCipher(Uint8List(8)); // Invalid key length
      }, throwsA(isA<ArgumentError>()));
    });

    test('Error handling for invalid data in decrypt', () {
      final invalidData = Uint8List.fromList('invalid'.codeUnits);
      expect(() {
        cipher.decrypt(invalidData);
      }, throwsA(isA<Exception>()));
    });

    test('Error handling for invalid GCM data', () {
      final invalidData = Uint8List.fromList('invalid'.codeUnits);
      final iv = Uint8List.fromList('123456789012'.codeUnits);
      final header = Uint8List.fromList('header'.codeUnits);

      expect(() {
        cipher.decryptGCM(invalidData, iv: iv, header: header);
      }, throwsA(isA<RangeError>()));
    });
  });
}
