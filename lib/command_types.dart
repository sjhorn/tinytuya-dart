// TinyTuya Module
// Command Types for Tuya Protocol

// Tuya Command Types
// Reference: https://github.com/tuya/tuya-iotos-embeded-sdk-wifi-ble-bk7231n/blob/master/sdk/include/lan_protocol.h
class CommandTypes {
  static const int AP_CONFIG =
      1; // FRM_TP_CFG_WF - only used for ap 3.0 network config
  static const int ACTIVE = 2; // FRM_TP_ACTV (discard) - WORK_MODE_CMD
  static const int SESS_KEY_NEG_START =
      3; // FRM_SECURITY_TYPE3 - negotiate session key
  static const int SESS_KEY_NEG_RESP =
      4; // FRM_SECURITY_TYPE4 - negotiate session key response
  static const int SESS_KEY_NEG_FINISH =
      5; // FRM_SECURITY_TYPE5 - finalize session key negotiation
  static const int UNBIND =
      6; // FRM_TP_UNBIND_DEV - DATA_QUERT_CMD - issue command
  static const int CONTROL = 7; // FRM_TP_CMD - STATE_UPLOAD_CMD
  static const int STATUS = 8; // FRM_TP_STAT_REPORT - STATE_QUERY_CMD
  static const int HEART_BEAT = 9; // FRM_TP_HB
  static const int DP_QUERY =
      0x0a; // 10 - FRM_QUERY_STAT - UPDATE_START_CMD - get data points
  static const int QUERY_WIFI =
      0x0b; // 11 - FRM_SSID_QUERY (discard) - UPDATE_TRANS_CMD
  static const int TOKEN_BIND =
      0x0c; // 12 - FRM_USER_BIND_REQ - GET_ONLINE_TIME_CMD - system time (GMT)
  static const int CONTROL_NEW = 0x0d; // 13 - FRM_TP_NEW_CMD - FACTORY_MODE_CMD
  static const int ENABLE_WIFI =
      0x0e; // 14 - FRM_ADD_SUB_DEV_CMD - WIFI_TEST_CMD
  static const int WIFI_INFO = 0x0f; // 15 - FRM_CFG_WIFI_INFO
  static const int DP_QUERY_NEW = 0x10; // 16 - FRM_QUERY_STAT_NEW
  static const int SCENE_EXECUTE = 0x11; // 17 - FRM_SCENE_EXEC
  static const int UPDATEDPS =
      0x12; // 18 - FRM_LAN_QUERY_DP - Request refresh of DPS
  static const int UDP_NEW = 0x13; // 19 - FR_TYPE_ENCRYPTION
  static const int AP_CONFIG_NEW = 0x14; // 20 - FRM_AP_CFG_WF_V40
  static const int BOARDCAST_LPV34 = 0x23; // 35 - FR_TYPE_BOARDCAST_LPV34
  static const int REQ_DEVINFO =
      0x25; // broadcast to port 7000 to get v3.5 devices to send their info
  static const int LAN_EXT_STREAM = 0x40; // 64 - FRM_LAN_EXT_STREAM
}
