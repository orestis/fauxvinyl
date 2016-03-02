#!/usr/bin/python

#from Foundation import *
from ScriptingBridge import SBApplication

class Spotify(object):
    PLAYING = 1800426320
    PAUSED = 1800426352

    def __init__(self):
        self.client = SBApplication.applicationWithBundleIdentifier_("com.spotify.client")


    def play_uri(self, uri):
        print "Playing", uri
        self.pause()
        self.client.setRepeating_(False)
        self.client.setShuffling_(False)
        self.client.playTrack_inContext_(uri, uri)
        self.play()


    def pause(self):
        self.client.pause()

    def play(self):
        self.client.play()

    def toggle(self):
        self.client.playpause()

    @property    
    def state(self):
        return self.client.playerState()


    def next(self):
        self.client.nextTrack()


    def previous(self):
        self.client.previousTrack()



class Album(object):
    def __init__(self, uri):
        self.uri = uri
        
        self.id = uri.split(":")[-1]




