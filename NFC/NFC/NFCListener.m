//
//  NFCListener.m
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import "NFCListener.h"
#import "Spotify.h"
@import ScriptingBridge;

@implementation NFCListener {
    SpotifyApplication *spotify;
    NSString *currentAlbumURI;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        spotify = [SBApplication applicationWithBundleIdentifier:@"com.spotify.client"];

        [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"NFCTagRead" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSLog(@"recieved notification %@", note);
            NSDictionary* userInfo = note.userInfo;
            NSLog(@"userInfo %@", userInfo);
            if ([userInfo[@"type"] isEqualToNumber:@(0)] ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *content = userInfo[@"content"];
                    if ([content isEqualToString:@"SPOTIFY_TOGGLE"]) {
                        [self spotifyToggle];
                    } else {
                        [self playSpotifyURI:content];
                    }
                });
            }
            
        }];
    }

    return self;
}

- (void)spotifyToggle {
    NSLog(@"playpause");
    [spotify playpause];
}

- (void)playSpotifyURI:(NSString*)uri {
    NSLog(@"playing uri %@", uri);
    if ([currentAlbumURI isEqualToString:uri]) {
        NSLog(@"skipping because already playint uri %@", currentAlbumURI);
        return;
    }
    currentAlbumURI = uri;
    [spotify pause];
    [spotify setRepeating:NO];
    [spotify setShuffling:NO];
    [spotify playTrack:uri inContext:uri];
    [spotify play];
    
}

@end
