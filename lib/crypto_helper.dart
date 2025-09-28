// TinyTuya Module
// AES Encryption/Decryption Helper

// coverage:ignore-start
import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
// coverage:ignore-end

class AESCipher {
  final Uint8List _key;

  AESCipher(Uint8List key) : _key = key {
    if (key.length != 16) {
      throw ArgumentError('AES key must be 16 bytes long');
    }
  }

  /// Pad data to block size (16 bytes) using PKCS7 padding
  static Uint8List _pad(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength);
    padded.setRange(0, data.length, data);
    for (int i = 0; i < padLength; i++) {
      padded[data.length + i] = padLength;
    }
    return padded;
  }

  /// Remove PKCS7 padding from data
  static Uint8List _unpad(Uint8List data, {bool verifyPadding = false}) {
    if (data.isEmpty) return data;

    final padLength = data.last;
    if (padLength < 1 || padLength > 16) {
      throw ArgumentError("Invalid padding length byte");
    }

    if (verifyPadding) {
      for (int i = 0; i < padLength; i++) {
        if (data[data.length - 1 - i] != padLength) {
          throw ArgumentError("Invalid padding data");
        }
      }
    }

    return data.sublist(0, data.length - padLength);
  }

  /// Encrypt data using AES-ECB
  Uint8List encrypt(Uint8List data, {bool useBase64 = true, bool pad = true}) {
    if (pad) {
      data = _pad(data, 16);
    }

    if (data.length % 16 != 0) {
      throw ArgumentError("Data length must be multiple of 16 for AES-ECB");
    }

    // Create AES cipher
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      ECBBlockCipher(AESEngine()),
    );

    // Initialize cipher for encryption
    final params = PaddedBlockCipherParameters(KeyParameter(_key), null);
    cipher.init(true, params);

    // Encrypt data
    final encrypted = Uint8List(data.length);
    int offset = 0;
    while (offset < data.length) {
      final blockSize = cipher.processBlock(data, offset, encrypted, offset);
      offset += blockSize;
    }

    if (useBase64) {
      return Uint8List.fromList(base64.encode(encrypted).codeUnits);
    }
    return encrypted;
  }

  /// Decrypt data using AES-ECB
  Uint8List decrypt(
    Uint8List data, {
    bool useBase64 = true,
    bool decodeText = true,
    bool verifyPadding = false,
  }) {
    Uint8List decrypted;

    if (useBase64) {
      final decoded = base64.decode(String.fromCharCodes(data));
      decrypted = Uint8List.fromList(decoded);
    } else {
      decrypted = data;
    }

    if (decrypted.length % 16 != 0) {
      throw ArgumentError("Invalid length: ${decrypted.length}");
    }

    // Create AES cipher
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      ECBBlockCipher(AESEngine()),
    );

    // Initialize cipher for decryption
    final params = PaddedBlockCipherParameters(KeyParameter(_key), null);
    cipher.init(false, params);

    // Decrypt data
    final result = Uint8List(decrypted.length);
    int offset = 0;
    while (offset < decrypted.length) {
      final blockSize = cipher.processBlock(decrypted, offset, result, offset);
      offset += blockSize;
    }

    if (verifyPadding) {
      return _unpad(result, verifyPadding: true);
    }

    return result;
  }

  /// Encrypt with GCM mode (for v3.5 devices)
  Uint8List encryptGCM(Uint8List data, {Uint8List? iv, Uint8List? header}) {
    if (iv == null) {
      // Generate random IV
      iv = Uint8List(12);
      final random = FortunaRandom();
      random.seed(KeyParameter(Uint8List(32)));
      random.nextBytes(iv.length);
    }

    // Create GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(_key),
      128,
      iv,
      header ?? Uint8List(0),
    );
    cipher.init(true, params);

    // Encrypt data
    final encrypted = cipher.process(data);

    // Return IV + encrypted data + tag
    final result = Uint8List(iv.length + encrypted.length);
    result.setRange(0, iv.length, iv);
    result.setRange(iv.length, iv.length + encrypted.length, encrypted);
    return result;
  }

  /// Decrypt with GCM mode (for v3.5 devices)
  Uint8List decryptGCM(
    Uint8List data, {
    Uint8List? iv,
    Uint8List? header,
    Uint8List? tag,
  }) {
    if (iv == null) {
      iv = data.sublist(0, 12);
      data = data.sublist(12);
    }

    // Create GCM cipher
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(_key),
      128,
      iv,
      header ?? Uint8List(0),
    );
    cipher.init(false, params);

    // Decrypt data
    return cipher.process(data);
  }
}
