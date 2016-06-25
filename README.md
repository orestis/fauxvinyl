# Faux-Vinyl

A collection of scripts/utilities that allows you to play
your favorite albums without having to suffer through Spotify's horrible UI.

## Web server
This is Mac-only, and it requires you have the Spotify client installed locally.
Also you have to run it with the system python or any PyObjC - enabled python
that allows you to use SBApplicationBridge.framework.

1. Maintain a collection of albums in the `albums.txt` file, one Spotify URI per line.

2. Run ./server.py and visit `http://localhost:9001`

3. Click on an album to play in Spotify.

## NFC tag integration
This is also Mac-only. It requires you to have a USB NFC tag reader. It still
uses the ScriptingBridge to control a local Spotify client.

Run both the NFC and the NFCListener apps. The first is doing the reading, while the
second waits for notifications and communicates with the spotify client.
The NFC app has a debug interface but that's not required for day-to-day use, only for writing
new values to the tags.

There is a simple data format:

2 byte header: 0x46 0x56
1 byte type - reserved: 0x00
1 byte length of payload.

Currently the type is always 0x00 and that is implied to be spotify. In the future
more types can be added and this can support iTunes etc.


## Bulk tag writing
Copy-paste gets old fast - you can use the command line BulkWriter application to write a lot
of tags in succession - just point it to your albums.txt. It will actually fetch some info from the 
Spotify Web API to prompt you which tag should go next.




## License

MIT License. See LICENSE.txt