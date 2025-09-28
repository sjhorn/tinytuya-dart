import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

void main() {
  group('Device Integration Tests', () {
    late Device device;

    setUp(() {
      device = Device(
        id: 'test_device_12345',
        address: '192.168.1.100',
        localKey: Uint8List.fromList('1234567890123456'.codeUnits),
        version: 3.4,
      );
    });

    tearDown(() {
      device.close();
    });

    test('Device creation with all parameters', () {
      final customDevice = Device(
        id: 'custom_device',
        address: '192.168.1.200',
        localKey: Uint8List.fromList('custom_key_16_chars'.codeUnits),
        devType: 'custom_type',
        version: 3.5,
        port: 6669,
        connectionTimeout: 10,
      );

      expect(customDevice.id, equals('custom_device'));
      expect(customDevice.address, equals('192.168.1.200'));
      expect(customDevice.devType, equals('custom_type'));
      expect(customDevice.version, equals(3.5));
      expect(customDevice.port, equals(6669));
      expect(customDevice.connectionTimeout, equals(10));
    });

    test('setSocketPersistent with true', () {
      device.setSocketPersistent(true);
      // This should not throw an error
    });

    test('setSocketPersistent with false', () {
      device.setSocketPersistent(false);
      // This should not throw an error
    });

    test('close method', () {
      device.close();
      // This should not throw an error
    });

    test('Debug mode setting', () {
      Device.setDebug(true);
      Device.setDebug(false);
      // This should not throw an error
    });

    test('Control methods return Future<bool>', () {
      expect(device.turnOn(), isA<Future<bool>>());
      expect(device.turnOff(), isA<Future<bool>>());
      expect(device.setValue(1, true), isA<Future<bool>>());
      expect(device.setValues({1: true}), isA<Future<bool>>());
    });

    test('Status method returns Future<Map<String, dynamic>?>', () {
      expect(device.status(), isA<Future<Map<String, dynamic>?>>());
    });

    test('Status method with nowait parameter', () {
      expect(device.status(nowait: true), isA<Future<Map<String, dynamic>?>>());
    });
  });
}
