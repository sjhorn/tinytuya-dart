// TinyTuya Module
// Header constants and structures for Tuya Protocol

import 'command_types.dart';

class Header {
  // Protocol Versions and Headers
  static const List<int> PROTOCOL_VERSION_BYTES_31 = [51, 46, 49]; // "3.1"
  static const List<int> PROTOCOL_VERSION_BYTES_33 = [51, 46, 51]; // "3.3"
  static const List<int> PROTOCOL_VERSION_BYTES_34 = [51, 46, 52]; // "3.4"
  static const List<int> PROTOCOL_VERSION_BYTES_35 = [51, 46, 53]; // "3.5"
  static const List<int> PROTOCOL_3x_HEADER = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ]; // 12 * 0
  static const List<int> PROTOCOL_33_HEADER = [
    ...PROTOCOL_VERSION_BYTES_33,
    ...PROTOCOL_3x_HEADER,
  ];
  static const List<int> PROTOCOL_34_HEADER = [
    ...PROTOCOL_VERSION_BYTES_34,
    ...PROTOCOL_3x_HEADER,
  ];
  static const List<int> PROTOCOL_35_HEADER = [
    ...PROTOCOL_VERSION_BYTES_35,
    ...PROTOCOL_3x_HEADER,
  ];

  // Message formats
  static const String MESSAGE_HEADER_FMT =
      ">4I"; // 4*uint32: prefix, seqno, cmd, length [, retcode]
  static const String MESSAGE_HEADER_FMT_55AA = ">4I";
  static const String MESSAGE_HEADER_FMT_6699 =
      ">IHIII"; // 4*uint32: prefix, unknown, seqno, cmd, length
  static const String MESSAGE_RETCODE_FMT =
      ">I"; // retcode for received messages
  static const String MESSAGE_END_FMT = ">2I"; // 2*uint32: crc, suffix
  static const String MESSAGE_END_FMT_55AA = ">2I";
  static const String MESSAGE_END_FMT_HMAC = ">32sI"; // 32s:hmac, uint32:suffix
  static const String MESSAGE_END_FMT_6699 = ">16sI"; // 16s:tag, suffix

  // Prefix and Suffix values
  static const int PREFIX_VALUE = 0x000055AA;
  static const int PREFIX_55AA_VALUE = 0x000055AA;
  static const List<int> PREFIX_BIN = [0x00, 0x00, 0x55, 0xaa];
  static const List<int> PREFIX_55AA_BIN = [0x00, 0x00, 0x55, 0xaa];
  static const int SUFFIX_VALUE = 0x0000AA55;
  static const int SUFFIX_55AA_VALUE = 0x0000AA55;
  static const List<int> SUFFIX_BIN = [0x00, 0x00, 0xaa, 0x55];
  static const List<int> SUFFIX_55AA_BIN = [0x00, 0x00, 0xaa, 0x55];
  static const int PREFIX_6699_VALUE = 0x00006699;
  static const List<int> PREFIX_6699_BIN = [0x00, 0x00, 0x66, 0x99];
  static const int SUFFIX_6699_VALUE = 0x00009966;
  static const List<int> SUFFIX_6699_BIN = [0x00, 0x00, 0x99, 0x66];

  // Commands that don't need protocol header
  static const List<int> NO_PROTOCOL_HEADER_CMDS = [
    CommandTypes.DP_QUERY,
    CommandTypes.DP_QUERY_NEW,
    CommandTypes.UPDATEDPS,
    CommandTypes.HEART_BEAT,
    CommandTypes.SESS_KEY_NEG_START,
    CommandTypes.SESS_KEY_NEG_RESP,
    CommandTypes.SESS_KEY_NEG_FINISH,
    CommandTypes.LAN_EXT_STREAM,
  ];
}
