from bottle import route, run, template, static_file, redirect
from spotify import Spotify, Album

SPOTIFY = Spotify()


album_uris = """\
spotify:album:5uLfogUTD4gfj2md4mrJwv
spotify:album:6fQElzBNTiEMGdIeY0hy5l
spotify:album:4R7TQJ3SZGpbTV8kSq6POA
spotify:album:3LdlOZcV0dp7ePBXe2KAGa
spotify:album:7npBPiCHjPj8PVIGPuHXep
spotify:album:5eqcF7pWzHgWpGdEmHgeSN
spotify:album:1NoUvTyvwokGSPcqudblVQ
""".splitlines()
albums = []

for uri in album_uris:
    albums.append(Album(uri))

@route('/')
def index():
    return template("index", albums=albums, message=None)

@route('/play/<uri>')
def play(uri):
    SPOTIFY.play_uri(uri)
    redirect("/")


@route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')


run(host='localhost', port=9001, debug=True)