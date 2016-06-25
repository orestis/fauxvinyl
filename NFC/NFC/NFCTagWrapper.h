//
//  NFCTagWrapper.h
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

@import CryptoTokenKit;

#import <Foundation/Foundation.h>



@interface NFCTagWrapper : NSObject
@property (readonly) TKSmartCard* card;
@property (readonly) BOOL valid;
@property (readonly) BOOL sessionInProgress;
@property (readonly) NSData* nfcID;
@property (readonly) UInt8 memorySize;
- (instancetype)initWithSmartCard:(TKSmartCard*)card;

- (void)preread;
- (NSData*)getNFCID; //blocking
- (NSData*)syncReadBlock:(UInt8)block length:(NSNumber*)length;
- (BOOL)syncWriteBlock:(UInt8)block data:(NSData*)data;

- (NSData*)syncReadAllData;
- (void)syncWriteAllData:(NSData*)data;
- (NSString*)syncReadString;
- (void)syncWriteString:(NSString*)string;
- (void)tryFastReadWithCompletionBlock:(void(^)(BOOL success, NSData* tagID, UInt8 tagType, NSString* tagContent))completion;


@end
