import 'dart:convert';
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

void main(List<String> arguments) async {
  // Enable debug mode
  Device.setDebug(false);

  // Create device instance
  final device = Device(
    id: 'bff9dcd9353a327b67wvgf',
    address: '192.168.1.145',
    localKey: Uint8List.fromList(';B#tSrtX1#|#B)j`'.codeUnits),
    version: 3.4,
  );

  // Set socket persistent
  device.setSocketPersistent(true);

  try {
    print('🔌 Connecting to Tuya device...');

    // Get initial status
    print('\n📊 Getting device status...');
    final status = await device.status();
    if (status != null) {
      final encoder = JsonEncoder.withIndent('  ');
      print('Current Status:');
      print(encoder.convert(status));
    }

    // Test turn on
    print('\n🔛 Turning device ON...');
    final turnOnResult = await device.turnOn();
    print('Turn ON result: $turnOnResult');

    // Wait a moment
    await Future.delayed(Duration(seconds: 2));

    // Get status after turn on
    print('\n📊 Getting status after turn ON...');
    final statusAfterOn = await device.status();
    if (statusAfterOn != null) {
      final encoder = JsonEncoder.withIndent('  ');
      print('Status after ON:');
      print(encoder.convert(statusAfterOn));
    }

    // Test turn off
    print('\n🔴 Turning device OFF...');
    final turnOffResult = await device.turnOff();
    print('Turn OFF result: $turnOffResult');

    // Wait a moment
    await Future.delayed(Duration(seconds: 2));

    // Get status after turn off
    print('\n📊 Getting status after turn OFF...');
    final statusAfterOff = await device.status();
    if (statusAfterOff != null) {
      final encoder = JsonEncoder.withIndent('  ');
      print('Status after OFF:');
      print(encoder.convert(statusAfterOff));
    }

    // Test setValue for specific DPS
    print('\n🎛️ Setting DPS 1 to true using setValue...');
    final setValueResult = await device.setValue(1, true);
    print('Set value result: $setValueResult');

    // Wait a moment
    await Future.delayed(Duration(seconds: 2));

    // Test setValues for multiple DPS
    print('\n🎛️ Setting multiple DPS values...');
    final setValuesResult = await device.setValues({
      1: false,
      9: 100, // Example: brightness or some other numeric value
    });
    print('Set values result: $setValuesResult');

    // Wait a moment
    await Future.delayed(Duration(seconds: 2));

    // Final status
    print('\n📊 Final device status...');
    final finalStatus = await device.status();
    if (finalStatus != null) {
      final encoder = JsonEncoder.withIndent('  ');
      print('Final Status:');
      print(encoder.convert(finalStatus));
    }

    print('\n✅ Control example completed!');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    device.close();
  }
}
