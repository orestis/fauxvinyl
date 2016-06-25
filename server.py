#!/usr/bin/python
import sys

from bottle import route, run, template, static_file, redirect
from spotify import Spotify, Album

SPOTIFY = Spotify()

ALBUMS = "albums.txt"
if len(sys.argv) > 1:
    ALBUMS = sys.argv[1].strip()

@route('/')
def index():
    album_uris = open(ALBUMS).read().splitlines()
    albums = []

    for uri in album_uris:
        if uri.strip():
            albums.append(Album(uri))

    return template("index", albums=albums, message=None)

@route('/play/<uri>')
def play(uri):
    SPOTIFY.play_uri(uri)
    redirect("/")


@route('/static/<filename:path>')
def send_static(filename):
    return static_file(filename, root='static')


run(host='localhost', port=9001, debug=True)