import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';
import 'package:test/test.dart';

void main() {
  group('Basic TinyTuya Tests', () {
    test('Device creation', () {
      final device = Device(
        id: 'test_device',
        address: '192.168.1.100',
        localKey: Uint8List.fromList('1234567890123456'.codeUnits),
        version: 3.4,
      );

      expect(device.id, equals('test_device'));
      expect(device.address, equals('192.168.1.100'));
      expect(device.version, equals(3.4));
    });

    test('AES encryption basic functionality', () {
      final key = Uint8List.fromList('1234567890123456'.codeUnits);
      final cipher = AESCipher(key);
      final testData = Uint8List.fromList('Hello World!'.codeUnits);

      final encrypted = cipher.encrypt(testData, useBase64: false);
      final decrypted = cipher.decrypt(
        encrypted,
        useBase64: false,
        verifyPadding: true,
      );

      expect(decrypted, equals(testData));
    });

    test('Message packing basic functionality', () {
      final payload = Uint8List.fromList('test'.codeUnits);
      final message = TuyaMessage(
        1,
        CommandTypes.DP_QUERY,
        0,
        payload,
        0,
        true,
        Header.PREFIX_55AA_VALUE,
      );
      final packed = MessageHelper.packMessage(message);

      expect(packed.length, greaterThan(0));
      expect(packed[0], equals(0x00));
      expect(packed[1], equals(0x00));
      expect(packed[2], equals(0x55));
      expect(packed[3], equals(0xAA));
    });
  });
}
