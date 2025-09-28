import 'dart:convert';
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

void main(List<String> arguments) async {
  // Enable debug mode (equivalent to tinytuya.set_debug(True))
  Device.setDebug(true);

  // Create device instance (equivalent to the Python example)
  final device = Device(
    id: 'bff9dcd9353a327b67wvgf',
    address: '192.168.1.145',
    localKey: Uint8List.fromList(';B#tSrtX1#|#B)j`'.codeUnits),
    version: 3.4,
  );

  // Set socket persistent (equivalent to d.set_socketPersistent(True))
  device.setSocketPersistent(true);

  try {
    // Get device status (equivalent to d.status())
    print('Connecting to device...');
    final status = await device.status();

    if (status != null) {
      // Pretty print the JSON response (equivalent to json.dumps(d.status(), indent=2))
      final encoder = JsonEncoder.withIndent('  ');
      print('Device Status:');
      print(encoder.convert(status));
    } else {
      print('Failed to get device status');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    // Close the connection
    device.close();
  }
}
