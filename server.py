from bottle import route, run, template, static_file, redirect
from spotify import Spotify, Album

SPOTIFY = Spotify()


album_uris = open("albums.txt").read().splitlines()
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