/// TinyTuya Dart Library
///
/// A Dart implementation of the TinyTuya Python library for controlling
/// Tuya smart devices over the local network using the Tuya protocol.
///
/// This library supports Tuya protocol versions 3.4 and 3.5, including
/// the 3-way handshake, AES encryption, and device control commands.

// coverage:ignore-start
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'command_types.dart';
import 'header.dart';
import 'crypto_helper.dart';
import 'message_helper.dart';
// coverage:ignore-end

/// Main Device class for communicating with Tuya smart devices.
///
/// This class handles the complete Tuya protocol implementation including:
/// - TCP socket connection management
/// - 3-way handshake for session key negotiation
/// - AES encryption/decryption of messages
/// - Device control commands (turn on/off, set values)
/// - Status queries and data point (DPS) management
class Device {
  /// Device ID (e.g., 'bff9dcd9353a327b67wvgf')
  final String id;

  /// Device IP address (e.g., '192.168.1.145')
  final String address;

  /// Local encryption key for the device
  final Uint8List localKey;

  /// Device type (default: 'default')
  final String devType;

  /// Tuya protocol version (default: 3.4)
  final double version;

  /// TCP port for communication (default: 6668)
  final int port;

  /// Connection timeout in seconds (default: 5)
  final int connectionTimeout;

  // Private fields for internal state management
  Socket? _socket;
  bool _socketPersistent = false;
  int _seqno = 1;
  Uint8List? _sessionKey;
  Uint8List? _localNonce;
  Uint8List? _remoteNonce;
  AESCipher? _cipher;
  StreamSubscription? _socketSubscription;
  final List<Completer<TuyaMessage?>> _responseCompleters = [];
  static bool _debugMode = false;

  /// Creates a new Device instance.
  ///
  /// [id] is the device ID from the Tuya app.
  /// [address] is the IP address of the device on the local network.
  /// [localKey] is the local encryption key from the Tuya app.
  /// [devType] is the device type (default: 'default').
  /// [version] is the Tuya protocol version (default: 3.4).
  /// [port] is the TCP port for communication (default: 6668).
  /// [connectionTimeout] is the connection timeout in seconds (default: 5).
  Device({
    required this.id,
    required this.address,
    required this.localKey,
    this.devType = 'default',
    this.version = 3.4,
    this.port = 6668,
    this.connectionTimeout = 5,
  });

  /// Enables or disables debug output.
  ///
  /// When enabled, detailed information about protocol messages,
  /// encryption, and communication will be printed to the console.
  static void setDebug(bool toggle, {bool color = true}) {
    _debugMode = toggle;
    if (toggle) {
      print('Debug mode: enabled');
    }
  }

  /// Internal debug logging helper
  static void _debugLog(String message) {
    if (_debugMode) {
      print(message);
    }
  }

  /// Sets whether to keep the TCP socket connection open between commands.
  ///
  /// When [persist] is true, the socket remains open after each command,
  /// allowing for faster subsequent operations. When false, the socket
  /// is closed after each command (default behavior).
  void setSocketPersistent(bool persist) {
    _socketPersistent = persist;
    if (_socket != null && !persist) {
      _socket!.close();
      _socket = null;
    }
  }

  /// Get device status
  Future<Map<String, dynamic>?> status({bool nowait = false}) async {
    try {
      await _ensureConnection();

      final payload = _generatePayload(CommandTypes.DP_QUERY);
      final response = await _sendReceive(payload, getResponse: !nowait);

      if (response == null) return null;

      return _decodePayload(response.payload);
    } catch (e) {
      _debugLog('Error getting status: $e');
      return null;
    }
  }

  /// Turns the device on.
  ///
  /// This is equivalent to calling [setValue] with DPS 1 set to true.
  /// Returns true if the command was successful, false otherwise.
  Future<bool> turnOn() async {
    return await setValue(1, true);
  }

  /// Turns the device off.
  ///
  /// This is equivalent to calling [setValue] with DPS 1 set to false.
  /// Returns true if the command was successful, false otherwise.
  Future<bool> turnOff() async {
    return await setValue(1, false);
  }

  /// Sets a specific DPS (Data Point) value.
  ///
  /// [dpId] is the data point ID to set (e.g., 1 for power, 9 for brightness).
  /// [value] is the value to set (can be bool, int, String, etc.).
  ///
  /// Returns true if the command was successful, false otherwise.
  Future<bool> setValue(int dpId, dynamic value) async {
    try {
      await _ensureConnection();

      final payload = _generateControlPayload(dpId, value);
      final response = await _sendReceive(payload, getResponse: true);

      if (response == null) {
        _debugLog('No response to set_value request');
        return false;
      }

      // For control commands (cmd=7), empty payload indicates success
      if (response.cmd == CommandTypes.CONTROL) {
        if (response.payload.isEmpty) {
          _debugLog('Set value successful (empty response)');
          return true;
        } else {
          // Try to decode if there's actual payload
          final result = _decodePayload(response.payload);
          if (result != null) {
            _debugLog('Set value successful: $result');
            return true;
          }
        }
      }

      _debugLog('Set value failed: unexpected response');
      return false;
    } catch (e) {
      _debugLog('Error setting value: $e');
      return false;
    }
  }

  /// Sets multiple DPS values at once.
  ///
  /// [dps] is a Map where keys are DPS IDs and values are the values to set.
  /// For example: {1: true, 9: 100} sets DPS 1 to true and DPS 9 to 100.
  ///
  /// Returns true if the command was successful, false otherwise.
  Future<bool> setValues(Map<int, dynamic> dps) async {
    try {
      await _ensureConnection();

      final payload = _generateControlPayloadMultiple(dps);
      final response = await _sendReceive(payload, getResponse: true);

      if (response == null) {
        _debugLog('No response to set_values request');
        return false;
      }

      // For control commands (cmd=7), empty payload indicates success
      if (response.cmd == CommandTypes.CONTROL) {
        if (response.payload.isEmpty) {
          _debugLog('Set values successful (empty response)');
          return true;
        } else {
          // Try to decode if there's actual payload
          final result = _decodePayload(response.payload);
          if (result != null) {
            _debugLog('Set values successful: $result');
            return true;
          }
        }
      }

      _debugLog('Set values failed: unexpected response');
      return false;
    } catch (e) {
      _debugLog('Error setting values: $e');
      return false;
    }
  }

  /// Ensures we have a connection to the device.
  ///
  /// Establishes a TCP connection and performs session key negotiation
  /// for protocol versions 3.4 and above.
  Future<void> _ensureConnection() async {
    if (_socket != null && _socketPersistent) return;

    _debugLog('Connecting to $address:$port...');
    _socket = await Socket.connect(
      address,
      port,
      timeout: Duration(seconds: connectionTimeout),
    );
    _debugLog('Connected successfully');

    // Set up persistent listener
    _setupSocketListener();

    if (version >= 3.4) {
      _debugLog('Starting session key negotiation...');
      final success = await _negotiateSessionKey();
      if (!success) {
        // coverage:ignore-start
        _debugLog('Session key negotiation failed');
        _socket?.close();
        _socket = null;
        throw Exception('Session key negotiation failed');
        // coverage:ignore-end
      }
    }
  }

  /// Set up persistent socket listener
  void _setupSocketListener() {
    if (_socket == null) return;

    _socketSubscription = _socket!.listen(
      (data) {
        _debugLog(
          'Received ${data.length} bytes: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );

        // Try to parse the message
        try {
          final header = MessageHelper.parseHeader(Uint8List.fromList(data));
          _debugLog(
            'Header parsed: seqno=${header.seqno}, cmd=${header.cmd}, length=${header.length}, total=${header.totalLength}',
          );

          if (data.length >= header.totalLength) {
            // We have a complete message
            final messageData = Uint8List.fromList(
              data.sublist(0, header.totalLength),
            );

            // For session key negotiation, use local key for HMAC verification
            Uint8List? hmacKey = _sessionKey;
            if (_sessionKey == null) {
              hmacKey = localKey;
            }

            try {
              final message = MessageHelper.unpackMessage(
                messageData,
                hmacKey: hmacKey,
              );
              _debugLog(
                'Message unpacked successfully: cmd=${message.cmd}, payload length=${message.payload.length}',
              );

              // Complete the first waiting completer
              if (_responseCompleters.isNotEmpty) {
                final completer = _responseCompleters.removeAt(0);
                _debugLog('Completing completer with message');
                if (!completer.isCompleted) {
                  completer.complete(message);
                }
              } else {
                _debugLog('No waiting completers!');
              }
            } catch (e) {
              _debugLog('Error unpacking message: $e');
              // Complete with error
              if (_responseCompleters.isNotEmpty) {
                final completer = _responseCompleters.removeAt(0);
                if (!completer.isCompleted) {
                  completer.completeError(e);
                }
              }
            }
          }
        } catch (e) {
          _debugLog('Error parsing message: $e');
        }
      },
      onError: (error) {
        // coverage:ignore-start
        _debugLog('Socket error: $error');
        // Complete all waiting completers with error
        for (final completer in _responseCompleters) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
        _responseCompleters.clear();
        // coverage:ignore-end
      },
      onDone: () {
        // coverage:ignore-start
        _debugLog('Socket closed by remote');
        // Complete all waiting completers with error
        for (final completer in _responseCompleters) {
          if (!completer.isCompleted) {
            completer.completeError('Socket closed');
          }
        }
        _responseCompleters.clear();
        // coverage:ignore-end
      },
    );
  }

  /// Negotiate session key for v3.4+ devices
  Future<bool> _negotiateSessionKey() async {
    try {
      // Step 1: Send our nonce
      _localNonce = Uint8List.fromList('0123456789abcdef'.codeUnits);
      _remoteNonce = Uint8List(16);

      _debugLog('Sending session key negotiation step 1...');
      final step1Payload = MessagePayload(
        CommandTypes.SESS_KEY_NEG_START,
        _localNonce!,
      );
      final step1Message = await _sendReceive(step1Payload, getResponse: true);

      if (step1Message == null) {
        // coverage:ignore-start
        _debugLog('No response to session key negotiation step 1');
        return false;
        // coverage:ignore-end
      }

      // Step 2: Process response and send HMAC
      _debugLog('Received response, command: ${step1Message.cmd}');
      if (step1Message.cmd != CommandTypes.SESS_KEY_NEG_RESP) {
        // coverage:ignore-start
        _debugLog(
          'Session key negotiation failed: wrong command (expected ${CommandTypes.SESS_KEY_NEG_RESP}, got ${step1Message.cmd})',
        );
        return false;
        // coverage:ignore-end
      }

      Uint8List responsePayload = step1Message.payload;
      _debugLog('Response payload length: ${responsePayload.length}');

      // Decrypt response if needed (v3.4 devices encrypt the response)
      if (version == 3.4) {
        _debugLog('Decrypting response...');
        final cipher = AESCipher(localKey);
        responsePayload = cipher.decrypt(
          responsePayload,
          useBase64: false,
          decodeText: false,
        );
        _debugLog('Decrypted payload length: ${responsePayload.length}');
        _debugLog(
          'Decrypted payload: ${responsePayload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      }

      if (responsePayload.length < 48) {
        // coverage:ignore-start
        _debugLog(
          'Session key negotiation failed: response too short (${responsePayload.length} < 48)',
        );
        return false;
        // coverage:ignore-end
      }

      _remoteNonce = responsePayload.sublist(0, 16);
      _debugLog(
        'Remote nonce received: ${_remoteNonce!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      // Verify HMAC (device sends HMAC of our local nonce)
      _debugLog('Verifying HMAC...');
      final hmac = Hmac(sha256, localKey);
      final expectedHmac = hmac.convert(_localNonce!).bytes;
      final receivedHmac = responsePayload.sublist(16, 48);

      _debugLog(
        'Expected HMAC: ${expectedHmac.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );
      _debugLog(
        'Received HMAC: ${receivedHmac.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      if (!_listEquals(expectedHmac, receivedHmac)) {
        // coverage:ignore-start
        _debugLog('Session key negotiation failed: HMAC mismatch');
        return false;
        // coverage:ignore-end
      }

      // Step 3: Send our HMAC (we send HMAC of their remote nonce)
      _debugLog('Sending session key negotiation step 3...');
      final ourHmac = Hmac(sha256, localKey);
      final ourHmacBytes = ourHmac.convert(_remoteNonce!).bytes;

      final step3Payload = MessagePayload(
        CommandTypes.SESS_KEY_NEG_FINISH,
        Uint8List.fromList(ourHmacBytes),
      );
      await _sendReceive(step3Payload, getResponse: false);

      // Finalize session key
      _debugLog('Finalizing session key...');
      _finalizeSessionKey();

      return true;
    } catch (e) {
      // coverage:ignore-start
      _debugLog('Session key negotiation failed: $e');
      return false;
      // coverage:ignore-end
    }
  }

  /// Finalize the session key
  void _finalizeSessionKey() {
    // XOR local and remote nonces to create session key
    final sessionKey = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      sessionKey[i] = _localNonce![i] ^ _remoteNonce![i];
    }

    _debugLog(
      'Session key (XOR): ${sessionKey.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );

    // Encrypt session key using the original local key
    final cipher = AESCipher(localKey);
    if (version == 3.4) {
      // For v3.4, encrypt the session key directly
      _sessionKey = cipher.encrypt(sessionKey, useBase64: false, pad: false);
    } else {
      // For other versions, use IV-based encryption
      final iv = _localNonce!.sublist(0, 12);
      final encrypted = cipher.encrypt(
        sessionKey,
        useBase64: false,
        pad: false,
      );
      _sessionKey = encrypted.sublist(12, 28);
    }

    _debugLog(
      'Encrypted session key: ${_sessionKey!.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );

    // Create cipher with the encrypted session key
    _cipher = AESCipher(_sessionKey!);
    _debugLog('Session key negotiated successfully');
  }

  /// Generate payload for a command
  MessagePayload _generatePayload(int command, {Map<String, dynamic>? data}) {
    Map<String, dynamic> jsonData;

    if (command == CommandTypes.DP_QUERY ||
        command == CommandTypes.DP_QUERY_NEW) {
      jsonData = {}; // Empty for v3.4
    } else {
      jsonData = {
        'protocol': 5,
        't': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'data': data ?? {},
      };
    }

    final payload = json.encode(jsonData).replaceAll(' ', '');
    return MessagePayload(command, Uint8List.fromList(utf8.encode(payload)));
  }

  /// Generate control payload for setting a single DPS value
  MessagePayload _generateControlPayload(int dpId, dynamic value) {
    final jsonData = {
      'protocol': 5,
      't': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'data': {
        'dps': {dpId.toString(): value},
      },
    };

    final payload = json.encode(jsonData).replaceAll(' ', '');
    return MessagePayload(
      CommandTypes.CONTROL,
      Uint8List.fromList(utf8.encode(payload)),
    );
  }

  /// Generate control payload for setting multiple DPS values
  MessagePayload _generateControlPayloadMultiple(Map<int, dynamic> dps) {
    final dpsMap = <String, dynamic>{};
    for (final entry in dps.entries) {
      dpsMap[entry.key.toString()] = entry.value;
    }

    final jsonData = {
      'protocol': 5,
      't': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'data': {'dps': dpsMap},
    };

    final payload = json.encode(jsonData).replaceAll(' ', '');
    return MessagePayload(
      CommandTypes.CONTROL,
      Uint8List.fromList(utf8.encode(payload)),
    );
  }

  /// Send and receive data
  Future<TuyaMessage?> _sendReceive(
    MessagePayload payload, {
    bool getResponse = true,
  }) async {
    if (_socket == null) {
      await _ensureConnection();
    }

    // Encode message
    final message = _encodeMessage(payload);

    // If we need a response, add completer to queue before sending
    Completer<TuyaMessage?>? completer;
    if (getResponse) {
      completer = Completer<TuyaMessage?>();
      _responseCompleters.add(completer);
      _debugLog(
        'Added completer to queue before sending, total completers: ${_responseCompleters.length}',
      );
    }

    // Send data
    _socket!.add(message);
    await _socket!.flush();

    if (!getResponse) return null;

    // Wait a bit for the device to respond
    await Future.delayed(Duration(milliseconds: 200));

    // Wait for response
    try {
      final response = await completer!.future.timeout(
        Duration(seconds: connectionTimeout),
      );
      _debugLog('Received response: cmd=${response?.cmd}');
      return response;
    } catch (e) {
      _debugLog('Error waiting for response: $e');
      return null;
    }
  }

  /// Encode message for transmission
  Uint8List _encodeMessage(MessagePayload payload) {
    Uint8List data = payload.payload;
    Uint8List? hmacKey;

    if (version >= 3.4) {
      // For session key negotiation, use local key for HMAC
      if (payload.cmd == CommandTypes.SESS_KEY_NEG_START ||
          payload.cmd == CommandTypes.SESS_KEY_NEG_RESP ||
          payload.cmd == CommandTypes.SESS_KEY_NEG_FINISH) {
        hmacKey =
            localKey; // Use local key for HMAC during session key negotiation
      } else {
        hmacKey = _sessionKey; // Use session key for HMAC after negotiation
      }

      // Add version header for v3.4 (if not in NO_PROTOCOL_HEADER_CMDS)
      if (!Header.NO_PROTOCOL_HEADER_CMDS.contains(payload.cmd)) {
        final header = Uint8List.fromList(Header.PROTOCOL_34_HEADER);
        data = Uint8List.fromList([...header, ...data]);
        _debugLog('Added version header, total length: ${data.length}');
      } else {
        _debugLog('Skipping version header for command ${payload.cmd}');
      }

      _debugLog(
        'Final payload before encryption: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
      );

      // For session key negotiation, encrypt with local key
      if (payload.cmd == CommandTypes.SESS_KEY_NEG_START ||
          payload.cmd == CommandTypes.SESS_KEY_NEG_RESP ||
          payload.cmd == CommandTypes.SESS_KEY_NEG_FINISH) {
        // Encrypt session key negotiation messages with local key
        final localCipher = AESCipher(localKey);
        data = localCipher.encrypt(data, useBase64: false);
        _debugLog(
          'Encrypted session key message: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      } else if (_cipher != null) {
        // Encrypt with session key for other messages
        data = _cipher!.encrypt(data, useBase64: false);
        _debugLog(
          'Encrypted payload: ${data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
        );
      }
    }

    // Create message
    final message = TuyaMessage(
      _seqno++,
      payload.cmd,
      0,
      data,
      0,
      true,
      Header.PREFIX_55AA_VALUE,
    );

    final packed = MessageHelper.packMessage(message, hmacKey: hmacKey);
    _debugLog(
      'Packed message: ${packed.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
    return packed;
  }

  /// Decode payload from response
  Map<String, dynamic>? _decodePayload(Uint8List payload) {
    try {
      Uint8List decryptedPayload = payload;

      if (version == 3.4) {
        // Decrypt payload with session key
        if (_cipher != null) {
          _debugLog('Decrypting payload with session key...');
          decryptedPayload = _cipher!.decrypt(
            payload,
            useBase64: false,
            decodeText: false,
          );
          _debugLog(
            'Decrypted payload: ${decryptedPayload.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
          );
        }
      }

      // Convert to string and parse JSON
      final jsonString = utf8.decode(decryptedPayload);
      _debugLog('JSON string: $jsonString');

      // Remove padding bytes if present
      final cleanJsonString = jsonString.replaceAll(
        RegExp(r'[\x00-\x1F\x7F-\x9F]+$'),
        '',
      );
      _debugLog('Clean JSON string: $cleanJsonString');

      return json.decode(cleanJsonString);
    } catch (e) {
      _debugLog('Error decoding payload: $e');
      return null;
    }
  }

  /// Close connection
  void close() {
    _socketSubscription?.cancel();
    _socket?.close();
    _socket = null;
    _socketSubscription = null;

    // Complete all waiting completers with error
    for (final completer in _responseCompleters) {
      if (!completer.isCompleted) {
        completer.completeError('Connection closed');
      }
    }
    _responseCompleters.clear();
  }

  /// Helper method to compare byte lists
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'Device(id: $id, address: $address, version: $version)';
  }
}
