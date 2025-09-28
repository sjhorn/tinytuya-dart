import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

void main() {
  group('Device Comprehensive Tests', () {
    late Device device;

    setUp(() {
      device = Device(
        id: 'test_device_id',
        address: '192.168.1.100',
        localKey: Uint8List.fromList('1234567890123456'.codeUnits),
        version: 3.4,
      );
    });

    test('Device creation with all parameters', () {
      final device = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        devType: 'switch',
        version: 3.5,
        port: 6668,
        connectionTimeout: 10,
      );

      expect(device.id, equals('test_id'));
      expect(device.address, equals('192.168.1.1'));
      expect(device.devType, equals('switch'));
      expect(device.version, equals(3.5));
      expect(device.port, equals(6668));
      expect(device.connectionTimeout, equals(10));
    });

    test('Device creation with default parameters', () {
      final device = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
      );

      expect(device.devType, equals('default'));
      expect(device.version, equals(3.4));
      expect(device.port, equals(6668));
      expect(device.connectionTimeout, equals(5));
    });

    test('setSocketPersistent method', () {
      device.setSocketPersistent(true);
      // This is a void method, so we just test it doesn't throw
      expect(() => device.setSocketPersistent(false), returnsNormally);
    });

    test('close method', () {
      // Test that close doesn't throw even when no connection exists
      expect(() => device.close(), returnsNormally);
    });

    test('Debug mode setting', () {
      Device.setDebug(true);
      Device.setDebug(false);
      // Test that it doesn't throw
      expect(() => Device.setDebug(true, color: false), returnsNormally);
    });

    test('Control methods with mock device', () {
      // Test that control methods exist and are callable
      expect(device.turnOn, isA<Function>());
      expect(device.turnOff, isA<Function>());
      expect(device.setValue, isA<Function>());
      expect(device.setValues, isA<Function>());
    });

    test('Status method with mock device', () {
      // Test that status method exists and is callable
      expect(device.status, isA<Function>());
    });

    test('Device with different versions', () {
      final device34 = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        version: 3.4,
      );

      final device35 = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        version: 3.5,
      );

      expect(device34.version, equals(3.4));
      expect(device35.version, equals(3.5));
    });

    test('Device with different device types', () {
      final switchDevice = Device(
        id: 'switch_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        devType: 'switch',
      );

      final lightDevice = Device(
        id: 'light_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        devType: 'light',
      );

      expect(switchDevice.devType, equals('switch'));
      expect(lightDevice.devType, equals('light'));
    });

    test('Device with different ports', () {
      final device6668 = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        port: 6668,
      );

      final device6669 = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        port: 6669,
      );

      expect(device6668.port, equals(6668));
      expect(device6669.port, equals(6669));
    });

    test('Device with different connection timeouts', () {
      final device5s = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        connectionTimeout: 5,
      );

      final device10s = Device(
        id: 'test_id',
        address: '192.168.1.1',
        localKey: Uint8List.fromList('key1234567890123'.codeUnits),
        connectionTimeout: 10,
      );

      expect(device5s.connectionTimeout, equals(5));
      expect(device10s.connectionTimeout, equals(10));
    });
  });
}
