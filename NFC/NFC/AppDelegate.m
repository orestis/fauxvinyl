//
//  AppDelegate.m
//  NFC
//
//  Created by Orestis Markou on 18/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import "AppDelegate.h"
#import "NFCExplorer.h"
#import "NFCListener.h"

#import <CryptoTokenKit/CryptoTokenKit.h>

@interface NSData (fingerprint)
-(NSString *)fingerprint;
@end

@implementation NSData (fingerprint)
-(NSString *)fingerprint {
    NSMutableString * str = [NSMutableString string];
    for(int i = 0; i < [self length]; i++)
        [str appendFormat:@"%s%02x", i ? ":" : "", ((unsigned char *)[self bytes])[i]];
    [str appendFormat:@" (%lu bytes)", (unsigned long)[self  length]];
    return str;
}
@end

@interface AppDelegate ()

@property (nonatomic, retain) TKSmartCardSlotManager * mngr;
@property (nonatomic, retain) NSMutableArray * slots;
@property (nonatomic, retain) NSMutableArray * cards;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate {
    NFCExplorer *explorer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    explorer = [[NFCExplorer alloc] initWithNibName:nil bundle:nil];
    [self.window.contentView addSubview:explorer.view];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}



- (void)makeItBeep:(TKSmartCard *)sc {
    sc.cla = 0xFF;
    //   76543210
    UInt8 p2 = 0b10000000;
    UInt8 b[4] = {0x03, 0x03, 0x05, 0x00};
    NSData *data = [NSData dataWithBytes:b length:4];
    [sc sendIns:0x00 p1:0x40 p2:p2 data:data le:@(0x0) reply:^(NSData * _Nullable replyData, UInt16 sw, NSError * _Nullable error) {
        NSLog(@"error? %@", error);
        NSLog(@"got reply data %@", replyData);
        NSLog(@"SW:    %02x/%02x", sw >> 8, sw & 0xFF);
        
    }];
}

@end
