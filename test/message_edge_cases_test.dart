import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:tinytuya/message_helper.dart';
import 'package:tinytuya/header.dart';

void main() {
  group('Message Edge Cases Tests', () {
    test('packMessage with empty payload', () {
      final emptyPayload = Uint8List(0);
      final message = TuyaMessage(1, 10, 0, emptyPayload, 0, true, 0x55AA);
      final packed = MessageHelper.packMessage(message);
      expect(packed, isNotNull);
      expect(packed.length, greaterThan(0));
    });

    test('packMessage with single byte payload', () {
      final singleByte = Uint8List.fromList([0x42]);
      final message = TuyaMessage(1, 10, 0, singleByte, 0, true, 0x55AA);
      final packed = MessageHelper.packMessage(message);
      expect(packed, isNotNull);
      expect(packed.length, greaterThan(0));
    });

    test('packMessage with maximum payload', () {
      final maxPayload = Uint8List(1000);
      for (int i = 0; i < 1000; i++) {
        maxPayload[i] = i % 256;
      }
      final message = TuyaMessage(1, 10, 0, maxPayload, 0, true, 0x55AA);
      final packed = MessageHelper.packMessage(message);
      expect(packed, isNotNull);
      expect(packed.length, greaterThan(1000));
    });

    test('packMessage with HMAC key', () {
      final payload = Uint8List.fromList('test'.codeUnits);
      final hmacKey = Uint8List.fromList('1234567890123456'.codeUnits);
      final message = TuyaMessage(1, 10, 0, payload, 0, true, 0x55AA);
      final packed = MessageHelper.packMessage(message, hmacKey: hmacKey);
      expect(packed, isNotNull);
      expect(packed.length, greaterThan(0));
    });

    test('unpackMessage with minimal valid data', () {
      final minimalData = Uint8List.fromList([
        0x00, 0x00, 0x55, 0xAA, // prefix
        0x00, 0x00, 0x00, 0x01, // seqno
        0x00, 0x00, 0x00, 0x0A, // cmd
        0x00, 0x00, 0x00, 0x00, // length
        0x00, 0x00, 0x00, 0x00, // retcode
        0x00, 0x00, 0x00, 0x00, // CRC
        0x00, 0x00, 0xAA, 0x55, // suffix
      ]);

      final message = MessageHelper.unpackMessage(minimalData);
      expect(message, isNotNull);
      expect(message!.seqno, equals(1));
      expect(message.cmd, equals(10));
      expect(message.payload, isEmpty);
    });

    test('parseHeader with 55AA format', () {
      final data = Uint8List.fromList([
        0x00, 0x00, 0x55, 0xAA, // prefix
        0x00, 0x00, 0x00, 0x01, // seqno
        0x00, 0x00, 0x00, 0x0A, // cmd
        0x00, 0x00, 0x00, 0x04, // length
        0x00, 0x00, 0x00, 0x00, // retcode
      ]);

      final header = MessageHelper.parseHeader(data);
      expect(header, isNotNull);
      expect(header!.prefix, equals(Header.PREFIX_55AA_VALUE));
      expect(header.seqno, equals(1));
      expect(header.cmd, equals(10));
      expect(header.length, equals(4));
    });

    test('parseHeader with 6699 format', () {
      final data = Uint8List.fromList([
        0x00, 0x00, 0x66, 0x99, // prefix
        0x00, 0x00, 0x00, 0x00, // unknown
        0x00, 0x00, 0x00, 0x01, // seqno
        0x00, 0x00, 0x00, 0x0A, // cmd
        0x00, 0x00, 0x00, 0x04, // length
        0x00, 0x00, 0x00, 0x00, // retcode
      ]);

      final header = MessageHelper.parseHeader(data);
      expect(header, isNotNull);
      expect(header!.prefix, equals(Header.PREFIX_6699_VALUE));
      expect(header.seqno, equals(1));
      expect(header.cmd, equals(10));
      expect(header.length, equals(4));
    });

    test('TuyaMessage with all parameters', () {
      final payload = Uint8List.fromList('test'.codeUnits);
      final iv = Uint8List.fromList('123456789012'.codeUnits);

      final message = TuyaMessage(
        1, // seqno
        10, // cmd
        0, // retcode
        payload, // payload
        12345, // crc
        true, // crc_good
        0x55AA, // prefix
        iv, // iv
      );

      expect(message.seqno, equals(1));
      expect(message.cmd, equals(10));
      expect(message.retcode, equals(0));
      expect(message.payload, equals(payload));
      expect(message.crc, equals(12345));
      expect(message.crcGood, equals(true));
      expect(message.prefix, equals(0x55AA));
      expect(message.iv, equals(iv));
    });

    test('TuyaMessage with minimal parameters', () {
      final payload = Uint8List.fromList('test'.codeUnits);

      final message = TuyaMessage(
        1, // seqno
        10, // cmd
        0, // retcode
        payload, // payload
        12345, // crc
        true, // crc_good
        0x55AA, // prefix
      );

      expect(message.seqno, equals(1));
      expect(message.cmd, equals(10));
      expect(message.retcode, equals(0));
      expect(message.payload, equals(payload));
      expect(message.crc, equals(12345));
      expect(message.crcGood, equals(true));
      expect(message.prefix, equals(0x55AA));
      expect(message.iv, isNull);
    });

    test('TuyaHeader with 55AA format', () {
      final header = TuyaHeader(
        Header.PREFIX_55AA_VALUE,
        1, // seqno
        10, // cmd
        4, // length
        20, // totalLength
      );

      expect(header.prefix, equals(Header.PREFIX_55AA_VALUE));
      expect(header.seqno, equals(1));
      expect(header.cmd, equals(10));
      expect(header.length, equals(4));
      expect(header.totalLength, equals(20));
    });

    test('TuyaHeader with 6699 format', () {
      final header = TuyaHeader(
        Header.PREFIX_6699_VALUE,
        1, // seqno
        10, // cmd
        4, // length
        24, // totalLength
      );

      expect(header.prefix, equals(Header.PREFIX_6699_VALUE));
      expect(header.seqno, equals(1));
      expect(header.cmd, equals(10));
      expect(header.length, equals(4));
      expect(header.totalLength, equals(24));
    });
  });
}
