The following code is the debug output of example.py
```
~/dev/tuya
❯ python example.py 
set_status() result {'dps': {'1': True, '9': 0, '18': 0, '19': 0, '20': 2284, '21': 1, '22': 567, '23': 27486, '24': 14977, '25': 2790, '26': 0, '38': 'memory', '39': False, '40': 'relay', '41': False, '42': '', '43': '', '44': ''}}

~/dev/tuya
❯ python example.py
DEBUG:TinyTuya [1.17.4]

DEBUG:Python 3.11.6 (main, Dec  3 2023, 10:00:30) [Clang 15.0.0 (clang-1500.0.40.1)] on darwin
DEBUG:Using pyca/cryptography 45.0.7 for crypto, GCM is supported
DEBUG:status() entry (dev_type is default)
DEBUG:final payload_dict for 'bff9dcd9353a327b67wvgf' ('v3.4'/'default'): {1: {'command': {'gwId': '', 'devId': '', 'uid': '', 't': ''}}, 7: {'command': {'protocol': 5, 't': 'int', 'data': {}}, 'command_override': 13}, 8: {'command': {'gwId': '', 'devId': ''}}, 9: {'command': {'gwId': '', 'devId': ''}}, 10: {'command': {}, 'command_override': 16}, 13: {'command': {'protocol': 5, 't': 'int', 'data': {}}}, 16: {'command': {}}, 18: {'command': {'dpId': [18, 19, 20]}}, 64: {'command': {'reqType': '', 'data': {}}}}
DEBUG:building command 10 payload=b'{}'
DEBUG:sending payload quick
DEBUG:final payload: b'0123456789abcdef'
DEBUG:payload encrypted=b'000055aa00000001000000030000004405a04f18459f60573296cbe1d82d595abd2e89587dcbb8472bef792a11f5f4c4ff7b279f191ba3a1f720978ef46971df4fad388d2aae8efdfa0ca69afd0d7e1c0000aa55'
DEBUG:received data=b'000055aa00009617000000040000006800000000840dd41382650fa819eceacaa5bf99d3a4ce7985b77a9c029c85cdc11dde3088627862fcee9666f915e19e220423bf83bd2e89587dcbb8472bef792a11f5f4c400b245b57e86759c6f66ac6b9cfc3d72997362e07bff7ca9f265b1e9690829350000aa55'
DEBUG:decrypting=b'\x84\r\xd4\x13\x82e\x0f\xa8\x19\xec\xea\xca\xa5\xbf\x99\xd3\xa4\xcey\x85\xb7z\x9c\x02\x9c\x85\xcd\xc1\x1d\xde0\x88bxb\xfc\xee\x96f\xf9\x15\xe1\x9e"\x04#\xbf\x83\xbd.\x89X}\xcb\xb8G+\xefy*\x11\xf5\xf4\xc4'
DEBUG:decrypted session key negotiation step 2 payload=b'5d2f11cb444f932b\xe5)\x18\xab8\xfcFxu\xf5Bp\xe9\xd7\x10zJ\x96\xcfjAu\xd6\xd6\xbf\xe0\xd9Q\x07\x1eu\xed'
DEBUG:payload type = <class 'bytes'> len = 48
DEBUG:session local nonce: b'0123456789abcdef' remote nonce: b'5d2f11cb444f932b'
DEBUG:sending payload quick
DEBUG:final payload: b'9\x94b\xad\xe3^\xc6\xc5\xbb\xa9 \x14s\xdd.\x19/R\xc9\x81\n\xd8%\\%;\x05\x1c\xa3\x8b\xbd\x13'
DEBUG:payload encrypted=b'000055aa000000020000000500000054fd58b870d9c05b9dee68402b17da9df22b85a68f7f03d668a537437285f232eebd2e89587dcbb8472bef792a11f5f4c4123961728687be8efacf23b95395d68cfb21a75802b1f06c7822162d2110ac680000aa55'
DEBUG:Session nonce XOR'd: b'\x05U\x00U\x05\x04UU\x0c\rU\x04ZWW\x04'
DEBUG:Session key negotiate success! session key: b'\x1f\x8a\xc4!"\xbe\xaay\xd1\x1f\xea\xf3&\x05\xad+'
DEBUG:sending payload
DEBUG:final payload: b'{}'
DEBUG:payload encrypted=b'000055aa0000000300000010000000346ccf29505e2503e82118fc0ce9ddccce4972e3f3f7f5d911ad4ad44921a6a19d5fe00ca506c101fca6054e04e696f5210000aa55'
DEBUG:received data=b'000055aa0000961800000010000000e800000000394e56ef37c5067c5450df49ac121f637f8560ab6529e6178442f8c7960eda0e6fc0c43bf2bd43beb0ef74ef8e6a3eb60754103f66f57efe47ff4bda28204e0b46b16ca72c3397b01156b0c593269357c6e808b3d47339751626937e6eae28c0a46b0ee80bdb268beb9d6e0b8413e1ec9f619732e8504c2468a7e6087694b6e4c4a9dc7e769822d43727c9c1032367bc53a683a61f17fed2c0980bb54c78e2bf97ca3fe2b38b7b01ccbbbd155bdf9ffe7b3b62acf8ea38e6ae56bf9bfce3e9487f709b76a917ebb8752e2227c11a7d519c9ecefb4c7d5ba86dadccc41b1497bf0000aa55'
DEBUG:received message=TuyaMessage(seqno=38424, cmd=16, retcode=0, payload=b'9NV\xef7\xc5\x06|TP\xdfI\xac\x12\x1fc\x7f\x85`\xabe)\xe6\x17\x84B\xf8\xc7\x96\x0e\xda\x0eo\xc0\xc4;\xf2\xbdC\xbe\xb0\xeft\xef\x8ej>\xb6\x07T\x10?f\xf5~\xfeG\xffK\xda( N\x0bF\xb1l\xa7,3\x97\xb0\x11V\xb0\xc5\x93&\x93W\xc6\xe8\x08\xb3\xd4s9u\x16&\x93~n\xae(\xc0\xa4k\x0e\xe8\x0b\xdb&\x8b\xeb\x9dn\x0b\x84\x13\xe1\xec\x9fa\x972\xe8PL$h\xa7\xe6\x08v\x94\xb6\xe4\xc4\xa9\xdc~v\x98"\xd47\'\xc9\xc1\x03#g\xbcS\xa6\x83\xa6\x1f\x17\xfe\xd2\xc0\x98\x0b\xb5Lx\xe2\xbf\x97\xca?\xe2\xb3\x8b{\x01\xcc\xbb\xbd\x15[\xdf\x9f\xfe{;b\xac\xf8\xea8\xe6\xaeV\xbf\x9b\xfc\xe3\xe9H', crc=b'\x7fp\x9bv\xa9\x17\xeb\xb8u."\'\xc1\x1a}Q\x9c\x9e\xce\xfbL}[\xa8m\xad\xcc\xc4\x1b\x14\x97\xbf', crc_good=True, prefix=21930, iv=None)
DEBUG:raw unpacked message = TuyaMessage(seqno=38424, cmd=16, retcode=0, payload=b'9NV\xef7\xc5\x06|TP\xdfI\xac\x12\x1fc\x7f\x85`\xabe)\xe6\x17\x84B\xf8\xc7\x96\x0e\xda\x0eo\xc0\xc4;\xf2\xbdC\xbe\xb0\xeft\xef\x8ej>\xb6\x07T\x10?f\xf5~\xfeG\xffK\xda( N\x0bF\xb1l\xa7,3\x97\xb0\x11V\xb0\xc5\x93&\x93W\xc6\xe8\x08\xb3\xd4s9u\x16&\x93~n\xae(\xc0\xa4k\x0e\xe8\x0b\xdb&\x8b\xeb\x9dn\x0b\x84\x13\xe1\xec\x9fa\x972\xe8PL$h\xa7\xe6\x08v\x94\xb6\xe4\xc4\xa9\xdc~v\x98"\xd47\'\xc9\xc1\x03#g\xbcS\xa6\x83\xa6\x1f\x17\xfe\xd2\xc0\x98\x0b\xb5Lx\xe2\xbf\x97\xca?\xe2\xb3\x8b{\x01\xcc\xbb\xbd\x15[\xdf\x9f\xfe{;b\xac\xf8\xea8\xe6\xaeV\xbf\x9b\xfc\xe3\xe9H', crc=b'\x7fp\x9bv\xa9\x17\xeb\xb8u."\'\xc1\x1a}Q\x9c\x9e\xce\xfbL}[\xa8m\xad\xcc\xc4\x1b\x14\x97\xbf', crc_good=True, prefix=21930, iv=None)
DEBUG:decode payload=b'9NV\xef7\xc5\x06|TP\xdfI\xac\x12\x1fc\x7f\x85`\xabe)\xe6\x17\x84B\xf8\xc7\x96\x0e\xda\x0eo\xc0\xc4;\xf2\xbdC\xbe\xb0\xeft\xef\x8ej>\xb6\x07T\x10?f\xf5~\xfeG\xffK\xda( N\x0bF\xb1l\xa7,3\x97\xb0\x11V\xb0\xc5\x93&\x93W\xc6\xe8\x08\xb3\xd4s9u\x16&\x93~n\xae(\xc0\xa4k\x0e\xe8\x0b\xdb&\x8b\xeb\x9dn\x0b\x84\x13\xe1\xec\x9fa\x972\xe8PL$h\xa7\xe6\x08v\x94\xb6\xe4\xc4\xa9\xdc~v\x98"\xd47\'\xc9\xc1\x03#g\xbcS\xa6\x83\xa6\x1f\x17\xfe\xd2\xc0\x98\x0b\xb5Lx\xe2\xbf\x97\xca?\xe2\xb3\x8b{\x01\xcc\xbb\xbd\x15[\xdf\x9f\xfe{;b\xac\xf8\xea8\xe6\xaeV\xbf\x9b\xfc\xe3\xe9H'
DEBUG:decrypting=b'9NV\xef7\xc5\x06|TP\xdfI\xac\x12\x1fc\x7f\x85`\xabe)\xe6\x17\x84B\xf8\xc7\x96\x0e\xda\x0eo\xc0\xc4;\xf2\xbdC\xbe\xb0\xeft\xef\x8ej>\xb6\x07T\x10?f\xf5~\xfeG\xffK\xda( N\x0bF\xb1l\xa7,3\x97\xb0\x11V\xb0\xc5\x93&\x93W\xc6\xe8\x08\xb3\xd4s9u\x16&\x93~n\xae(\xc0\xa4k\x0e\xe8\x0b\xdb&\x8b\xeb\x9dn\x0b\x84\x13\xe1\xec\x9fa\x972\xe8PL$h\xa7\xe6\x08v\x94\xb6\xe4\xc4\xa9\xdc~v\x98"\xd47\'\xc9\xc1\x03#g\xbcS\xa6\x83\xa6\x1f\x17\xfe\xd2\xc0\x98\x0b\xb5Lx\xe2\xbf\x97\xca?\xe2\xb3\x8b{\x01\xcc\xbb\xbd\x15[\xdf\x9f\xfe{;b\xac\xf8\xea8\xe6\xaeV\xbf\x9b\xfc\xe3\xe9H'
DEBUG:decrypted 3.x payload=b'{"dps":{"1":true,"9":0,"18":0,"19":0,"20":2284,"21":1,"22":567,"23":27486,"24":14977,"25":2790,"26":0,"38":"memory","39":false,"40":"relay","41":false,"42":"","43":"","44":""}}'
DEBUG:payload type = <class 'bytes'>
DEBUG:decoded results='{"dps":{"1":true,"9":0,"18":0,"19":0,"20":2284,"21":1,"22":567,"23":27486,"24":14977,"25":2790,"26":0,"38":"memory","39":false,"40":"relay","41":false,"42":"","43":"","44":""}}'
DEBUG:caching: {'dps': {'1': True, '9': 0, '18': 0, '19': 0, '20': 2284, '21': 1, '22': 567, '23': 27486, '24': 14977, '25': 2790, '26': 0, '38': 'memory', '39': False, '40': 'relay', '41': False, '42': '', '43': '', '44': ''}}
DEBUG:merged: {'dps': {'1': True, '9': 0, '18': 0, '19': 0, '20': 2284, '21': 1, '22': 567, '23': 27486, '24': 14977, '25': 2790, '26': 0, '38': 'memory', '39': False, '40': 'relay', '41': False, '42': '', '43': '', '44': ''}}
DEBUG:status() received data={'dps': {'1': True, '9': 0, '18': 0, '19': 0, '20': 2284, '21': 1, '22': 567, '23': 27486, '24': 14977, '25': 2790, '26': 0, '38': 'memory', '39': False, '40': 'relay', '41': False, '42': '', '43': '', '44': ''}}
{
  "dps": {
    "1": true,
    "9": 0,
    "18": 0,
    "19": 0,
    "20": 2284,
    "21": 1,
    "22": 567,
    "23": 27486,
    "24": 14977,
    "25": 2790,
    "26": 0,
    "38": "memory",
    "39": false,
    "40": "relay",
    "41": false,
    "42": "",
    "43": "",
    "44": ""
  }
}
```