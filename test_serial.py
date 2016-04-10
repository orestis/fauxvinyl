import serial
import json
import os
import time

ser = serial.Serial('/dev/tty.usbserial', 9600)
print ser
ser.baudrate = 9600
print ser
print ser.name

PLAY = '\x07\x07G'
PAUSE = '\x07\x07J'
STOP = '\x07\x07F'
NEXT = '\x07\x07H'
PREVIOUS = '\x07\x07E'
VOL_UP = '\x07\x07\x07'
VOL_DOWN = '\x07\x07\x0b'
MUTE = '\x07\x07\x0f'

RETURN = '\x07\x07X'
INFO = '\x07\x07\x1f'

CENTER = '\x07\x07h'
RIGHT = '\x07\x07b'
LEFT = '\x07\x07e'
DOWN = '\x07\x07a'
UP = '\x07\x07`'

A = '\x07\x07l'
B = '\x07\x07\x14'
C = '\x07\x07\x15'
D = '\x07\x07\x16'


plex_commands = {
    RETURN: "Input.Back",
    A: "Input.ContextMenu",
    B: "Input.ShowOSD",
    INFO: "Input.Info",

    UP: "Input.Up",
    DOWN: "Input.Down",
    LEFT: "Input.Left",
    RIGHT: "Input.Right",
    CENTER: "Input.Select",
    PLAY: ("Player.PlayPause", {"playerid":1}),
    PAUSE: ("Player.PlayPause", {"playerid":1}),
    STOP: ("Player.Stop", {"playerid":1}),
}

LAST_TIME = time.time()

def debounce(delay):
    now = time.time()
    diff = now - LAST_TIME
    return diff < delay





HOST = 'localhost'
#HOST = 'edm-mini-orestis.local'
def send_plex_command(cmd, params=None):
    payload = {"id":1, "jsonrpc":"2.0", "method":cmd}
    if params:
        payload["params"] = params
    line = """curl -v -H "Accept: application/json" -H "Content-type: application/json" -X POST -d '{}' {}:3005/jsonrpc""".format(json.dumps(payload), HOST)
    os.system(line)

while True:
    try:
        print "Waiting for command..."
        x = ser.read(3)
        if debounce(0.3):
            print "SKIPPING, debounce"
            continue
        try:
            LAST_TIME = time.time()
            cmd = plex_commands[x]
            params = None
            if not isinstance(cmd, basestring):
                cmd, params = cmd
            print "COMMAND", cmd, params
            send_plex_command(cmd, params)

        except KeyError:
            print "unrecognised command", repr(x)
    except KeyboardInterrupt:
        break

ser.close()
