//
//  AppDelegate.m
//  NFCListener
//
//  Created by Orestis Markou on 20/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import "AppDelegate.h"
#import "NFCListener.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    NFCListener *listener;

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
        listener = [[NFCListener alloc] init];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
