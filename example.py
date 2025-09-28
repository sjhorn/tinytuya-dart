# save as sniff34.py
import tinytuya, os, json
tinytuya.set_debug(True)               # dumps 55AA…AA55 frames
d = tinytuya.Device(
    'bff9dcd9353a327b67wvgf', 
    '192.168.1.145', 
    ';B#tSrtX1#|#B)j`', 
    version=3.4
)
# keep TCP open so you see the whole handshake + first command
d.set_socketPersistent(True)
print(json.dumps(d.status(), indent=2)) # triggers handshake + status