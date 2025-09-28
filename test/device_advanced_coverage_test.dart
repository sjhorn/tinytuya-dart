import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/tinytuya.dart';

void main() {
  group('Device Advanced Coverage Tests', () {
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

    group('Device Status Method', () {
      test('status with nowait=true', () async {
        final result = await device.status(nowait: true);
        expect(result, isNull);
      });

      test('status with nowait=false', () async {
        final result = await device.status(nowait: false);
        expect(result, isNull);
      });

      test('status with invalid device', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.status();
        expect(result, isNull);
        invalidDevice.close();
      });
    });

    group('Control Methods', () {
      test('turnOn with invalid device', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.turnOn();
        expect(result, isFalse);
        invalidDevice.close();
      });

      test('turnOff with invalid device', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        final result = await invalidDevice.turnOff();
        expect(result, isFalse);
        invalidDevice.close();
      });

      test('setValue with various types', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        // Test with boolean
        final boolResult = await invalidDevice.setValue(1, true);
        expect(boolResult, isFalse);

        // Test with integer
        final intResult = await invalidDevice.setValue(2, 100);
        expect(intResult, isFalse);

        // Test with string
        final stringResult = await invalidDevice.setValue(3, 'test');
        expect(stringResult, isFalse);

        // Test with double
        final doubleResult = await invalidDevice.setValue(4, 3.14);
        expect(doubleResult, isFalse);

        invalidDevice.close();
      });

      test('setValues with various combinations', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        // Test with mixed types
        final result = await invalidDevice.setValues({
          1: true,
          2: 100,
          3: 'test',
          4: 3.14,
          5: false,
        });
        expect(result, isFalse);

        invalidDevice.close();
      });
    });

    group('Connection Error Handling', () {
      test('Connection with invalid IP format', () async {
        final invalidDevice = Device(
          id: 'test',
          address: 'invalid-ip',
          localKey: testKey,
        );

        final result = await invalidDevice.status();
        expect(result, isNull);
        invalidDevice.close();
      });

      test('Connection with unreachable host', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '10.255.255.1', // Likely unreachable
          localKey: testKey,
        );

        final result = await invalidDevice.status();
        expect(result, isNull);
        invalidDevice.close();
      });

      test('Connection with very short timeout', () async {
        final timeoutDevice = Device(
          id: 'test',
          address: '192.168.1.1',
          localKey: testKey,
          connectionTimeout: 0, // Very short timeout
        );

        final result = await timeoutDevice.status();
        expect(result, isNull);
        timeoutDevice.close();
      });
    });

    group('Protocol Version Handling', () {
      test('Version 3.3 device (below 3.4)', () async {
        final v33Device = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
          version: 3.3,
        );

        final result = await v33Device.status();
        expect(result, isNull);
        v33Device.close();
      });

      test('Version 3.6 device (above 3.5)', () async {
        final v36Device = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
          version: 3.6,
        );

        final result = await v36Device.status();
        expect(result, isNull);
        v36Device.close();
      });
    });

    group('Device Type Handling', () {
      test('Device with custom devType', () async {
        final customDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
          devType: 'custom_type',
        );

        expect(customDevice.devType, equals('custom_type'));
        final result = await customDevice.status();
        expect(result, isNull);
        customDevice.close();
      });
    });

    group('Port and Timeout Configuration', () {
      test('Device with custom port', () async {
        final customPortDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
          port: 6669,
        );

        expect(customPortDevice.port, equals(6669));
        final result = await customPortDevice.status();
        expect(result, isNull);
        customPortDevice.close();
      });

      test('Device with custom timeout', () async {
        final customTimeoutDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
          connectionTimeout: 10,
        );

        expect(customTimeoutDevice.connectionTimeout, equals(10));
        final result = await customTimeoutDevice.status();
        expect(result, isNull);
        customTimeoutDevice.close();
      });
    });

    group('Socket Management', () {
      test('setSocketPersistent with different values', () {
        expect(() => device.setSocketPersistent(true), returnsNormally);
        expect(() => device.setSocketPersistent(false), returnsNormally);
        expect(() => device.setSocketPersistent(true), returnsNormally);
      });

      test('Multiple close calls', () {
        expect(() => device.close(), returnsNormally);
        expect(() => device.close(), returnsNormally);
        expect(() => device.close(), returnsNormally);
      });

      test('Operations after close', () async {
        device.close();

        // These should not throw
        expect(() => device.setSocketPersistent(true), returnsNormally);

        final statusResult = await device.status();
        expect(statusResult, isNull);

        final turnOnResult = await device.turnOn();
        expect(turnOnResult, isFalse);

        final turnOffResult = await device.turnOff();
        expect(turnOffResult, isFalse);

        final setValueResult = await device.setValue(1, true);
        expect(setValueResult, isFalse);

        final setValuesResult = await device.setValues({1: true});
        expect(setValuesResult, isFalse);
      });
    });

    group('Debug Mode', () {
      test('Debug mode affects all operations', () async {
        Device.setDebug(true);

        // All operations should work with debug mode
        expect(() => device.setSocketPersistent(true), returnsNormally);
        final statusResult = await device.status();
        expect(statusResult, isNull);

        Device.setDebug(false);

        // All operations should work without debug mode
        expect(() => device.setSocketPersistent(false), returnsNormally);
        final statusResult2 = await device.status();
        expect(statusResult2, isNull);
      });
    });

    group('Edge Cases', () {
      test('Device with null-like values', () {
        final emptyKey = Uint8List(0);
        final device = Device(
          id: '',
          address: '192.168.1.1',
          localKey: emptyKey,
        );

        expect(device.id, equals(''));
        expect(device.localKey, equals(emptyKey));
        expect(() => device.close(), returnsNormally);
      });

      test('Device with maximum values', () {
        final maxKey = Uint8List(32); // Maximum key length
        final device = Device(
          id: 'a' * 1000, // Very long ID
          address: '192.168.1.1',
          localKey: maxKey,
          port: 65535, // Maximum port
          connectionTimeout: 300, // Very long timeout
        );

        expect(device.id.length, equals(1000));
        expect(device.localKey.length, equals(32));
        expect(device.port, equals(65535));
        expect(device.connectionTimeout, equals(300));
        expect(() => device.close(), returnsNormally);
      });

      test('Device with special characters', () {
        final specialId = 'test-device_id@123!#\$%';
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
      test('Multiple status calls', () async {
        final futures = <Future<Map<String, dynamic>?>>[];

        for (int i = 0; i < 5; i++) {
          futures.add(device.status());
        }

        final results = await Future.wait(futures);
        for (final result in results) {
          expect(result, isNull);
        }
      });

      test('Multiple control calls', () async {
        final futures = <Future<bool>>[];

        futures.add(device.turnOn());
        futures.add(device.turnOff());
        futures.add(device.setValue(1, true));
        futures.add(device.setValues({1: false, 2: true}));

        final results = await Future.wait(futures);
        for (final result in results) {
          expect(result, isFalse);
        }
      });

      test('Mixed operations', () async {
        final futures = <Future>[];

        futures.add(device.status());
        futures.add(device.turnOn());
        futures.add(device.status(nowait: true));
        futures.add(device.turnOff());

        final results = await Future.wait(futures);
        expect(results.length, equals(4));
      });
    });

    group('Error Recovery', () {
      test('Operations after connection failure', () async {
        final invalidDevice = Device(
          id: 'test',
          address: '192.168.1.999',
          localKey: testKey,
        );

        // First operation fails
        final status1 = await invalidDevice.status();
        expect(status1, isNull);

        // Subsequent operations should also fail gracefully
        final turnOn = await invalidDevice.turnOn();
        expect(turnOn, isFalse);

        final turnOff = await invalidDevice.turnOff();
        expect(turnOff, isFalse);

        final setValue = await invalidDevice.setValue(1, true);
        expect(setValue, isFalse);

        final setValues = await invalidDevice.setValues({1: true});
        expect(setValues, isFalse);

        invalidDevice.close();
      });
    });
  });
}
