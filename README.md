Faux-Vinyl

A collection of scripts/utilities that allows you to play
your favorite albums without having to suffer through Spotify's horrible UI.

This is Mac-only, and it requires you have the Spotify client installed locally.
Also you have to run it with the system python or any PyObjC - enabled python
that allows you to use SBApplicationBridge.framework.

1. Maintain a collection of albums in the `albums.txt` file, one Spotify URI per line.

2. Run ./server.py and visit `http://localhost:9001`

3. Click on an album to play in Spotify.
