# TinyTuya Dart Library

[![pub package](https://img.shields.io/pub/v/tinytuya.svg)](https://pub.dev/packages/tinytuya)
[![Dart CI](https://github.com/your-username/tinytuya-dart/workflows/Dart%20CI/badge.svg)](https://github.com/your-username/tinytuya-dart/actions)
[![codecov](https://codecov.io/gh/your-username/tinytuya-dart/branch/main/graph/badge.svg)](https://codecov.io/gh/your-username/tinytuya-dart)
[![Coverage](https://img.shields.io/badge/coverage-37%25-orange.svg)](https://github.com/your-username/tinytuya-dart)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Dart port of the [TinyTuya Python library](https://github.com/jasonacox/tinytuya) for controlling Tuya smart devices over the local network using the Tuya protocol.

## Features

- 🏠 **Local Control**: Control Tuya devices directly over your local network
- 🔐 **Secure**: Full implementation of Tuya protocol 3.4 with AES encryption
- 🚀 **Fast**: Persistent socket connections for rapid device control
- 📱 **Cross-Platform**: Works on Android, iOS, Linux, macOS, Web, and Windows
- 🧪 **Well Tested**: 37% code coverage with comprehensive unit tests
- 📚 **Well Documented**: Complete API documentation and examples

## Supported Devices

This library supports Tuya smart devices including:
- Smart plugs and outlets
- Smart lights and bulbs
- Smart switches
- Smart sensors
- And many more Tuya-compatible devices

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tinytuya: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

void main() async {
  // Create a device instance
  final device = Device(
    id: 'your_device_id',
    address: '192.168.1.100',
    localKey: Uint8List.fromList('your_local_key'.codeUnits),
    version: 3.4,
  );

  // Enable debug mode (optional)
  Device.setDebug(true);

  // Set persistent connection for faster operations
  device.setSocketPersistent(true);

  try {
    // Get device status
    final status = await device.status();
    print('Device status: $status');

    // Turn device on/off
    await device.turnOn();
    await device.turnOff();

    // Set specific values
    await device.setValue(1, true);  // Turn on
    await device.setValue(9, 100);   // Set brightness to 100

    // Set multiple values at once
    await device.setValues({
      1: false,  // Turn off
      9: 50,     // Set brightness to 50
    });

  } finally {
    // Always close the connection
    device.close();
  }
}
```

## API Reference

### Device Class

The main class for communicating with Tuya devices.

#### Constructor

```dart
Device({
  required String id,           // Device ID from Tuya app
  required String address,      // Device IP address
  required Uint8List localKey,  // Local encryption key
  String devType = 'default',   // Device type
  double version = 3.4,         // Protocol version
  int port = 6668,              // TCP port
  int connectionTimeout = 5,    // Connection timeout in seconds
})
```

#### Methods

##### `status({bool nowait = false})`
Gets the current status of the device.

**Returns:** `Future<Map<String, dynamic>?>` - Device status data

##### `turnOn()`
Turns the device on (equivalent to `setValue(1, true)`).

**Returns:** `Future<bool>` - Success status

##### `turnOff()`
Turns the device off (equivalent to `setValue(1, false)`).

**Returns:** `Future<bool>` - Success status

##### `setValue(int dpId, dynamic value)`
Sets a specific DPS (Data Point) value.

**Parameters:**
- `dpId`: Data point ID (e.g., 1 for power, 9 for brightness)
- `value`: Value to set (bool, int, String, etc.)

**Returns:** `Future<bool>` - Success status

##### `setValues(Map<int, dynamic> dps)`
Sets multiple DPS values at once.

**Parameters:**
- `dps`: Map of DPS IDs to values

**Returns:** `Future<bool>` - Success status

##### `setSocketPersistent(bool persist)`
Sets whether to keep the TCP socket connection open between commands.

**Parameters:**
- `persist`: `true` to keep connection open, `false` to close after each command

##### `close()`
Closes the device connection.

#### Static Methods

##### `setDebug(bool toggle, {bool color = true})`
Enables or disables debug output.

**Parameters:**
- `toggle`: `true` to enable debug output, `false` to disable
- `color`: `true` to enable colored output (default: `true`)

## Examples

### Basic Device Control

```dart
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

void main() async {
  final device = Device(
    id: 'bff9dcd9353a327b67wvgf',
    address: '192.168.1.145',
    localKey: Uint8List.fromList(';B#tSrtX1#|#B)j`'.codeUnits),
    version: 3.4,
  );

  device.setSocketPersistent(true);

  try {
    // Get initial status
    final status = await device.status();
    print('Initial status: $status');

    // Turn device on
    await device.turnOn();
    print('Device turned on');

    // Set brightness to 75%
    await device.setValue(9, 75);
    print('Brightness set to 75%');

    // Turn device off
    await device.turnOff();
    print('Device turned off');

  } finally {
    device.close();
  }
}
```

### Flutter Integration

```dart
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

class SmartDeviceController {
  late Device _device;
  bool _isOn = false;
  int _brightness = 0;

  Future<void> initialize() async {
    _device = Device(
      id: 'your_device_id',
      address: '192.168.1.100',
      localKey: Uint8List.fromList('your_local_key'.codeUnits),
      version: 3.4,
    );
    _device.setSocketPersistent(true);
    
    // Get initial status
    final status = await _device.status();
    if (status != null) {
      _isOn = status['dps']['1'] ?? false;
      _brightness = status['dps']['9'] ?? 0;
    }
  }

  Future<void> togglePower() async {
    if (_isOn) {
      await _device.turnOff();
    } else {
      await _device.turnOn();
    }
    _isOn = !_isOn;
  }

  Future<void> setBrightness(int value) async {
    await _device.setValue(9, value);
    _brightness = value;
  }

  void dispose() {
    _device.close();
  }
}
```

## Protocol Support

This library supports:
- **Tuya Protocol 3.4**: Full 3-way handshake with AES encryption
- **Tuya Protocol 3.5**: GCM encryption support
- **Session Key Negotiation**: Secure key exchange
- **HMAC Verification**: Message integrity checking
- **Persistent Connections**: Fast device control

## Getting Device Credentials

To use this library, you need:
1. **Device ID**: Found in the Tuya Smart app
2. **Local Key**: The encryption key for your device
3. **IP Address**: The device's IP on your local network

### Finding Device Credentials

1. Open the Tuya Smart app
2. Go to your device settings
3. Look for "Device Information" or similar
4. Note down the Device ID and Local Key
5. Find the device's IP address in your router's admin panel

## Testing

Run the test suite:

```bash
dart test
```

Run with coverage:

```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib
genhtml coverage/lcov.info -o coverage/html
```

Current test coverage: **37%** (209 of 559 lines)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [TinyTuya Python Library](https://github.com/jasonacox/tinytuya) - Original Python implementation
- [TuyaAPI](https://github.com/codetheweb/tuyapi) - Protocol reverse engineering
- [PyTuya](https://github.com/clach04/python-tuya) - Original Python module

## Related Projects

- [TinyTuya Python](https://github.com/jasonacox/tinytuya) - Original Python library
- [LocalTuya Home Assistant](https://github.com/rospogrigio/localtuya-homeassistant) - Home Assistant integration

## Support

If you find this library helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 🤝 Contributing code

---

**Made with ❤️ for the Dart and Flutter community**