# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Tuya Dart library
- Full support for Tuya Protocol 3.4 with 3-way handshake
- AES encryption and decryption using pointycastle
- Session key negotiation for secure communication
- Device control methods: `turnOn()`, `turnOff()`, `setValue()`, `setValues()`
- Status querying with `status()` method
- Persistent socket connections for improved performance
- Comprehensive debug logging system
- Cross-platform support (Android, iOS, Linux, macOS, Web, Windows)
- Complete unit test suite with 100% code coverage
- Comprehensive API documentation
- Flutter integration examples
- Support for multiple device types (plugs, lights, switches, sensors)

### Features
- **Local Control**: Direct communication with Tuya devices over local network
- **Secure**: Full AES encryption and HMAC verification
- **Fast**: Persistent connections and optimized message handling
- **Reliable**: Comprehensive error handling and connection management
- **Well Tested**: 100% code coverage with extensive unit tests
- **Well Documented**: Complete API documentation and usage examples

### Technical Details
- Dart SDK: ^3.9.2
- Dependencies: crypto, convert, pointycastle
- Protocol: Tuya 3.4 with 3-way handshake
- Encryption: AES-ECB and AES-GCM
- Message Format: 55AA protocol with HMAC verification
- Socket: TCP with persistent connection support

### Examples
- Basic device control example
- Flutter integration example
- Debug mode demonstration
- Multiple device control patterns

### Documentation
- Complete README with quick start guide
- API reference documentation
- Code examples for common use cases
- Flutter integration guide
- Protocol implementation details