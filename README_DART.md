# TinyTuya Dart Library

A Dart port of the TinyTuya Python library for controlling Tuya smart devices.

## Overview

This library provides a Dart implementation of the TinyTuya protocol, allowing you to communicate with Tuya smart devices over your local network. It supports the 3.4 protocol version with 3-way handshake and encryption.

## Features

- ✅ Protocol 3.4 support with 3-way handshake
- ✅ AES encryption/decryption
- ✅ Message packing/unpacking
- ✅ Device status querying
- ✅ Socket communication
- ✅ Session key negotiation

## Project Structure

```
lib/
├── tinytuya.dart         # Main library exports
├── device.dart            # Main Device class
├── command_types.dart     # Tuya command constants
├── header.dart           # Protocol header constants
├── crypto_helper.dart    # AES encryption/decryption
└── message_helper.dart   # Message packing/unpacking
```

## Usage

### Basic Example

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:tinytuya/tinytuya.dart';

void main() async {
  // Enable debug mode
  Device.setDebug(true);
  
  // Create device instance
  final device = Device(
    id: 'your_device_id',
    address: '192.168.1.145',
    localKey: Uint8List.fromList('your_local_key'.codeUnits),
    version: 3.4,
  );
  
  // Set socket persistent
  device.setSocketPersistent(true);
  
  try {
    // Get device status
    final status = await device.status();
    
    if (status != null) {
      final encoder = JsonEncoder.withIndent('  ');
      print('Device Status:');
      print(encoder.convert(status));
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    device.close();
  }
}
```

### Running the Example

```bash
# Install dependencies
dart pub get

# Run the main example (requires real device)
dart run bin/tuya.dart

# Run basic structure test
dart run test_simple.dart
```

## Protocol Implementation

### 3-Way Handshake (Protocol 3.4)

1. **Step 1**: Client sends local nonce
2. **Step 2**: Device responds with remote nonce + HMAC
3. **Step 3**: Client sends HMAC of remote nonce
4. **Finalize**: Session key = XOR(local_nonce, remote_nonce)

### Message Format

```
[Header][Payload][CRC/Suffix]
- Header: 16 bytes (prefix, seqno, cmd, length)
- Payload: Variable length (encrypted JSON)
- CRC/Suffix: 8 bytes (CRC32 + 0xAA55)
```

### Encryption

- Uses AES-ECB mode for basic encryption
- Session key derived from nonce exchange
- HMAC-SHA256 for message authentication

## Current Status

This is a **proof-of-concept implementation** that demonstrates the core structure and protocol understanding. The current implementation includes:

- ✅ Basic protocol structure
- ✅ Message packing/unpacking
- ✅ 3-way handshake logic
- ✅ AES encryption framework
- ✅ Device class structure

### Limitations

- Socket communication needs refinement for production use
- AES implementation is simplified (placeholder XOR)
- Error handling could be more robust
- No device discovery/scanning yet

## Comparison with Python Version

The Dart implementation follows the same structure as the Python TinyTuya library:

| Feature | Python | Dart | Status |
|---------|--------|------|--------|
| Protocol 3.4 | ✅ | ✅ | Implemented |
| 3-way handshake | ✅ | ✅ | Implemented |
| AES encryption | ✅ | 🔄 | Basic structure |
| Message packing | ✅ | ✅ | Implemented |
| Device class | ✅ | ✅ | Implemented |
| Socket handling | ✅ | 🔄 | Needs refinement |

## Next Steps

To make this production-ready:

1. **Improve AES implementation** - Use proper AES-ECB/GCM libraries
2. **Fix socket communication** - Handle streaming data properly
3. **Add device discovery** - Implement network scanning
4. **Error handling** - More robust error management
5. **Testing** - Add comprehensive unit tests
6. **Documentation** - Complete API documentation

## Dependencies

- `crypto: ^3.0.3` - For HMAC and hashing
- `convert: ^3.1.1` - For base64 encoding
- `http: ^1.1.0` - For HTTP requests (future)
- `socket_io_client: ^2.0.3+1` - For socket communication (future)

## License

This project follows the same license as the original TinyTuya Python library.

## Credits

Based on the excellent work by the TinyTuya Python library authors:
- Jason A. Cox (jasonacox)
- And all contributors to the original project
