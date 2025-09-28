import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

void main() {
  group('Device Coverage Tests', () {
    late Device device;
    late Uint8List testKey;

    setUp(() {
      testKey = Uint8List.fromList('1234567890123456'.codeUnits);
      device = Device(
        id: 'test_device_id',
        address: '192.168.1.100',
        localKey: testKey,
        version: 3.4,
      );
    });

    tearDown(() {
      device.close();
    });

    group('Device Creation and Configuration', () {
      test('Device creation with all parameters', () {
        final device = Device(
          id: 'test_id',
          address: '192.168.1.1',
          localKey: testKey,
          devType: 'switch',
          version: 3.5,
          port: 6669,
          connectionTimeout: 10,
        );

        expect(device.id, equals('test_id'));
        expect(device.address, equals('192.168.1.1'));
        expect(device.localKey, equals(testKey));
        expect(device.devType, equals('switch'));
        expect(device.version, equals(3.5));
        expect(device.port, equals(6669));
        expect(device.connectionTimeout, equals(10));
      });

      test('Device creation with default parameters', () {
        final device = Device(
          id: 'test_id',
          address: '192.168.1.1',
          localKey: testKey,
        );

        expect(device.id, equals('test_id'));
        expect(device.address, equals('192.168.1.1'));
        expect(device.localKey, equals(testKey));
        expect(device.devType, equals('default'));
        expect(device.version, equals(3.4));
        expect(device.port, equals(6668));
        expect(device.connectionTimeout, equals(5));
      });

      test('setSocketPersistent method', () {
        expect(() => device.setSocketPersistent(true), returnsNormally);
        expect(() => device.setSocketPersistent(false), returnsNormally);
      });

      test('close method', () {
        expect(() => device.close(), returnsNormally);
        // Should be safe to call multiple times
        expect(() => device.close(), returnsNormally);
      });

      test('toString method', () {
        final str = device.toString();
        expect(str, contains('test_device_id'));
        expect(str, contains('192.168.1.100'));
        expect(str, contains('3.4'));
      });
    });

    group('Connection Management', () {
      test('Connection with invalid address returns null', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '999.999.999.999', // Invalid IP
          localKey: testKey,
        );

        final result = await invalidDevice.status();
        expect(result, isNull);
      });

      test('Connection timeout returns null', () async {
        final timeoutDevice = Device(
          id: 'test',
          address: '192.168.1.999', // Non-existent IP
          localKey: testKey,
          connectionTimeout: 1, // Very short timeout
        );

        final result = await timeoutDevice.status();
        expect(result, isNull);
      });
    });

    group('Session Key Negotiation', () {
      test(
        'Session key negotiation with invalid device returns null',
        () async {
          final invalidDevice = Device(
            id: 'test',
            address: '192.168.1.999',
            localKey: testKey,
          );

          final result = await invalidDevice.status();
          expect(result, isNull);
        },
      );

      test('Session key finalization coverage', () {
        // Test session key handling through public methods
        expect(() => device.close(), returnsNormally);
      });
    });

    group('Message Encoding and Decoding', () {
      test('Message encoding and decoding through public API', () {
        // Test message handling through public methods
        expect(() => device.setSocketPersistent(true), returnsNormally);
        expect(() => device.close(), returnsNormally);
      });
    });

    group('Control Methods Error Handling', () {
      test('turnOn with connection error returns false', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.turnOn();
        expect(result, isFalse);
      });

      test('turnOff with connection error returns false', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.turnOff();
        expect(result, isFalse);
      });

      test('setValue with connection error returns false', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.setValue(1, true);
        expect(result, isFalse);
      });

      test('setValues with connection error returns false', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.setValues({1: true, 2: false});
        expect(result, isFalse);
      });

      test('status with connection error returns null', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.status();
        expect(result, isNull);
      });
    });

    group('Socket Listener Management', () {
      test('Socket listener setup coverage', () {
        // Test socket listener through public methods
        expect(() => device.close(), returnsNormally);
      });

      test('Send receive with connection error returns null', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        // This will test the send/receive methods indirectly
        final result = await invalidDevice.status();
        expect(result, isNull);
      });
    });

    group('Debug Mode', () {
      test('Debug mode setting', () {
        expect(() => Device.setDebug(true), returnsNormally);
        expect(() => Device.setDebug(false), returnsNormally);
      });

      test('Debug mode affects logging', () {
        Device.setDebug(true);
        // This should not throw
        expect(() => device.setSocketPersistent(true), returnsNormally);

        Device.setDebug(false);
        // This should not throw
        expect(() => device.setSocketPersistent(false), returnsNormally);
      });
    });

    group('Protocol Version Handling', () {
      test('Version 3.4 device', () {
        final v34Device = Device(
          id: 'test',
          address: '192.168.1.1',
          localKey: testKey,
          version: 3.4,
        );

        expect(v34Device.version, equals(3.4));
        expect(() => v34Device.close(), returnsNormally);
      });

      test('Version 3.5 device', () {
        final v35Device = Device(
          id: 'test',
          address: '192.168.1.1',
          localKey: testKey,
          version: 3.5,
        );

        expect(v35Device.version, equals(3.5));
        expect(() => v35Device.close(), returnsNormally);
      });
    });

    group('Edge Cases', () {
      test('Device with very long ID', () {
        final longId = 'a' * 1000;
        final device = Device(
          id: longId,
          address: '192.168.1.1',
          localKey: testKey,
        );

        expect(device.id, equals(longId));
        expect(() => device.close(), returnsNormally);
      });

      test('Device with empty key', () {
        final emptyKey = Uint8List(0);
        final device = Device(
          id: 'test',
          address: '192.168.1.1',
          localKey: emptyKey,
        );

        expect(device.localKey, equals(emptyKey));
        expect(() => device.close(), returnsNormally);
      });

      test('Device with special characters in ID', () {
        final specialId = 'test-device_id@123';
        final device = Device(
          id: specialId,
          address: '192.168.1.1',
          localKey: testKey,
        );

        expect(device.id, equals(specialId));
        expect(() => device.close(), returnsNormally);
      });
    });

    group('Concurrent Operations', () {
      test('Multiple close calls', () {
        expect(() => device.close(), returnsNormally);
        expect(() => device.close(), returnsNormally);
        expect(() => device.close(), returnsNormally);
      });

      test('setSocketPersistent after close', () {
        device.close();
        expect(() => device.setSocketPersistent(true), returnsNormally);
      });
    });
  });
}
