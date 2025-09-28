// TinyTuya Module
// Message packing/unpacking for Tuya Protocol

// coverage:ignore-start
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'header.dart';
// coverage:ignore-end

class TuyaHeader {
  final int prefix;
  final int seqno;
  final int cmd;
  final int length;
  final int totalLength;

  TuyaHeader(this.prefix, this.seqno, this.cmd, this.length, this.totalLength);
}

class MessagePayload {
  final int cmd;
  final Uint8List payload;

  MessagePayload(this.cmd, this.payload);
}

class TuyaMessage {
  final int seqno;
  final int cmd;
  final int retcode;
  final Uint8List payload;
  final int crc;
  final bool crcGood;
  final int prefix;
  final Uint8List? iv;

  TuyaMessage(
    this.seqno,
    this.cmd,
    this.retcode,
    this.payload,
    this.crc,
    this.crcGood,
    this.prefix, [
    this.iv,
  ]);
}

class MessageHelper {
  /// Pack a TuyaMessage into bytes
  static Uint8List packMessage(TuyaMessage msg, {Uint8List? hmacKey}) {
    Uint8List data;

    if (msg.prefix == Header.PREFIX_55AA_VALUE) {
      // 55AA format
      final headerData = Uint8List(16); // 4 * 4 bytes
      _writeUint32(headerData, 0, msg.prefix);
      _writeUint32(headerData, 4, msg.seqno);
      _writeUint32(headerData, 8, msg.cmd);

      final endFmtSize = hmacKey != null
          ? 36
          : 8; // HMAC + suffix or CRC + suffix
      final msgLen = msg.payload.length + endFmtSize;
      _writeUint32(headerData, 12, msgLen);

      data = Uint8List(headerData.length + msg.payload.length + endFmtSize);
      data.setRange(0, headerData.length, headerData);
      data.setRange(
        headerData.length,
        headerData.length + msg.payload.length,
        msg.payload,
      );

      // Add CRC or HMAC
      final crcData = data.sublist(0, headerData.length + msg.payload.length);
      if (hmacKey != null) {
        final hmac = Hmac(sha256, hmacKey);
        final digest = hmac.convert(crcData);
        data.setRange(
          headerData.length + msg.payload.length,
          headerData.length + msg.payload.length + 32,
          digest.bytes,
        );
        _writeUint32(
          data,
          headerData.length + msg.payload.length + 32,
          Header.SUFFIX_VALUE,
        );
      } else {
        final crc = _crc32(crcData);
        _writeUint32(data, headerData.length + msg.payload.length, crc);
        _writeUint32(
          data,
          headerData.length + msg.payload.length + 4,
          Header.SUFFIX_VALUE,
        );
      }
    } else if (msg.prefix == Header.PREFIX_6699_VALUE) {
      // 6699 format - more complex, requires GCM encryption
      throw UnimplementedError('6699 format not yet implemented');
    } else {
      throw ArgumentError(
        'Unknown message format: ${msg.prefix.toRadixString(16)}',
      );
    }

    return data;
  }

  /// Parse header from received data
  static TuyaHeader parseHeader(Uint8List data) {
    if (data.length < 16) {
      throw ArgumentError('Not enough data to unpack header');
    }

    final prefix = _readUint32(data, 0);

    if (prefix == Header.PREFIX_55AA_VALUE) {
      final seqno = _readUint32(data, 4);
      final cmd = _readUint32(data, 8);
      final payloadLen = _readUint32(data, 12);
      final totalLength = payloadLen + 16;
      return TuyaHeader(prefix, seqno, cmd, payloadLen, totalLength);
    } else if (prefix == Header.PREFIX_6699_VALUE) {
      _readUint32(data, 4); // unknown field
      final seqno = _readUint32(data, 8);
      final cmd = _readUint32(data, 12);
      final payloadLen = _readUint32(data, 16);
      final totalLength = payloadLen + 20 + Header.SUFFIX_6699_BIN.length;
      return TuyaHeader(prefix, seqno, cmd, payloadLen, totalLength);
    } else {
      throw ArgumentError(
        'Header prefix wrong! ${prefix.toRadixString(16)} is not ${Header.PREFIX_55AA_VALUE.toRadixString(16)} or ${Header.PREFIX_6699_VALUE.toRadixString(16)}',
      );
    }
  }

  /// Unpack bytes into a TuyaMessage
  static TuyaMessage unpackMessage(
    Uint8List data, {
    Uint8List? hmacKey,
    TuyaHeader? header,
    bool noRetcode = false,
  }) {
    if (header == null) {
      header = parseHeader(data);
    }

    int retcode = 0;
    Uint8List payload;
    bool crcGood = false;
    Uint8List? iv;

    if (header.prefix == Header.PREFIX_55AA_VALUE) {
      final headerLen = 16;
      final retcodeLen = noRetcode ? 0 : 4;
      final msgLen = headerLen + header.length;

      if (data.length < msgLen) {
        throw ArgumentError('Not enough data to unpack payload');
      }

      if (retcodeLen > 0) {
        retcode = _readUint32(data, headerLen);
      }

      final endFmtSize = hmacKey != null ? 36 : 8;
      final payloadStart = headerLen + retcodeLen;
      final payloadEnd = msgLen - endFmtSize;
      if (payloadEnd > payloadStart) {
        payload = data.sublist(payloadStart, payloadEnd);
      } else {
        payload = Uint8List(0);
      }

      // Verify CRC or HMAC
      final crcData = data.sublist(0, msgLen - endFmtSize);
      if (hmacKey != null) {
        final hmac = Hmac(sha256, hmacKey);
        final expectedHmac = hmac.convert(crcData).bytes;
        final receivedHmac = data.sublist(msgLen - endFmtSize, msgLen - 4);
        crcGood = _listEquals(expectedHmac, receivedHmac);
      } else {
        final expectedCrc = _crc32(crcData);
        final receivedCrc = _readUint32(data, msgLen - endFmtSize);
        crcGood = expectedCrc == receivedCrc;
      }
    } else {
      throw UnimplementedError('6699 format not yet implemented');
    }

    return TuyaMessage(
      header.seqno,
      header.cmd,
      retcode,
      payload,
      0,
      crcGood,
      header.prefix,
      iv,
    );
  }

  /// Helper methods for reading/writing integers
  static int _readUint32(Uint8List data, int offset) {
    return (data[offset] << 24) |
        (data[offset + 1] << 16) |
        (data[offset + 2] << 8) |
        data[offset + 3];
  }

  static void _writeUint32(Uint8List data, int offset, int value) {
    data[offset] = (value >> 24) & 0xFF;
    data[offset + 1] = (value >> 16) & 0xFF;
    data[offset + 2] = (value >> 8) & 0xFF;
    data[offset + 3] = value & 0xFF;
  }

  /// Simple CRC32 implementation
  static int _crc32(Uint8List data) {
    int crc = 0xFFFFFFFF;
    for (int byte in data) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        if (crc & 1 != 0) {
          crc = (crc >> 1) ^ 0xEDB88320;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc ^ 0xFFFFFFFF;
  }

  /// Compare two byte lists
  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
