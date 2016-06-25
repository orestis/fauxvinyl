//
//  NFCExplorer.h
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//
@import CryptoTokenKit;
#import "NFCTagWrapper.h"

#import <Cocoa/Cocoa.h>

@interface NFCExplorer : NSViewController

@property (readonly) TKSmartCardSlot* reader;
@property (nonatomic, readonly) NFCTagWrapper* currentTag;

@property NSString *blockNumber;
@property NSString *byteCount;

@property IBOutlet NSTextField* blockContent;
@property IBOutlet NSTextField* asciiContent;

@property IBOutlet NSTextField* allContent;


- (IBAction)readDataBlock:(id)sender;
- (IBAction)writeDataBlock:(id)sender;

- (IBAction)readText:(id)sender;
- (IBAction)writeText:(id)sender;



@end