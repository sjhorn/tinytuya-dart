# TinyTuya Dart Library - Test Suite

This directory contains comprehensive unit tests for the TinyTuya Dart library, ensuring all functionality works correctly and remains stable during refactoring.

## Test Structure

### `tuya_test.dart`
Basic functionality tests that verify core components work correctly:
- Device creation and initialization
- AES encryption/decryption
- Message packing/unpacking

### `public_api_test.dart`
Comprehensive tests covering all public APIs and functionality:
- **Public API Tests**: Device creation, debug mode, socket management
- **AES Encryption Tests**: Various encryption scenarios, padding, base64 encoding
- **Message Helper Tests**: Packing, unpacking, header parsing with/without HMAC
- **Command Types Tests**: Verification of all command constants
- **Header Constants Tests**: Protocol version headers and command lists
- **Integration Tests**: Complete message flow simulation and JSON handling
- **Error Handling Tests**: Invalid inputs and error conditions
- **Protocol Compliance Tests**: 55AA message format and length field accuracy

## Running Tests

### Run All Tests
```bash
dart test
```

### Run Specific Test File
```bash
dart test test/tuya_test.dart
dart test test/public_api_test.dart
```

### Run with Test Runner Script
```bash
dart test_runner.dart
```

### Run with Verbose Output
```bash
dart test --verbose
```

## Test Coverage

The test suite covers:

✅ **AES Encryption**
- ECB mode encryption/decryption
- PKCS7 padding
- Base64 encoding/decoding
- Key validation
- Different data sizes

✅ **Message Protocol**
- 55AA message format compliance
- Header parsing and validation
- Message packing with/without HMAC
- Message unpacking and verification
- Length field accuracy

✅ **Device Communication**
- Device initialization
- Debug mode management
- Socket persistent settings
- Connection management

✅ **Protocol Compliance**
- Command type constants
- Header constants
- Protocol version headers
- NO_PROTOCOL_HEADER_CMDS list

✅ **Integration Testing**
- Complete message flow simulation
- JSON payload handling
- Real device response format parsing
- Error handling scenarios

✅ **Error Handling**
- Invalid AES key lengths
- Invalid message data
- JSON parsing errors
- Protocol violations

## Key Test Scenarios

### Real Device Communication
Tests include scenarios based on actual device communication patterns learned during development:
- Session key negotiation message formats
- Status request/response handling
- Padding removal from device responses
- Protocol 3.4 version header handling

### Protocol Compliance
All tests ensure the library maintains compatibility with the Tuya Protocol 3.4 specification:
- Correct message structure (55AA prefix, AA55 suffix)
- Accurate length field calculation
- Proper HMAC calculation and verification
- Command type and header constant validation

## Continuous Integration

These tests are designed to:
- Run quickly and reliably
- Catch regressions during refactoring
- Validate new features before integration
- Ensure protocol compliance is maintained
- Verify real device communication patterns

## Adding New Tests

When adding new functionality:
1. Add tests to the appropriate group in `public_api_test.dart`
2. Test both success and failure scenarios
3. Include edge cases and error conditions
4. Verify protocol compliance
5. Update this README if adding new test categories

## Test Dependencies

The tests use the standard Dart `test` package and require:
- `package:tinytuya` (the library being tested)
- `dart:typed_data` for Uint8List operations
- `dart:convert` for JSON handling

All tests are designed to run without external dependencies or network access, making them fast and reliable.
