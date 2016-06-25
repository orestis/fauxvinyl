//
//  NFCTagWrapper.m
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import "NFCTagWrapper.h"

typedef id (^APDUReplyBlock)(NSData * _Nullable , UInt16 , NSError * _Nullable );

@interface NFCTagWrapper ()
@property (readwrite) BOOL sessionInProgress;
@property (readwrite) NSData* nfcID;
@property (readwrite) UInt8 memorySize;
@property (readwrite) NSString* tagContent;
@property (readwrite) UInt8 tagType;


@end

@implementation NFCTagWrapper {

}
- (instancetype)initWithSmartCard:(TKSmartCard *)card {
    self = [super init];
    if (self) {
        _card = card;
        [_card addObserver:self forKeyPath:@"valid" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];
        

    }
    
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == _card && [keyPath isEqualToString:@"valid"]) {
        [self willChangeValueForKey:@"valid"];
        _valid = _card.valid;
//        if (_valid) {
//            [self preread];
//        }
        [self didChangeValueForKey:@"valid"];
    }
}

- (void)dealloc {
    [_card removeObserver:self forKeyPath:@"valid"];
   
}

- (void)preread {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{

        NSData *nfcID = [self getNFCID];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.nfcID = nfcID;
        });
        NSData *memorySize = [self syncReadBlock:3 length:@(4)];
        if (memorySize == nil) {
            return;
        }
        const void *bytes = [memorySize bytes];
        UInt8 *actualBytes = (UInt8*)bytes;
        UInt8 byte3 =  actualBytes[2];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"memorySize %d * 8 = %d ", byte3, byte3 * 8);
            self.memorySize = byte3 * 8;
        });
        
        
        
    });

    

}

- (void)tryFastReadWithCompletionBlock:(void(^)(BOOL success, NSData* tagID, UInt8 tagType, NSString* tagContent))completion {
    NSData *nfcID = [self getNFCID];
    NSData *header = [self syncReadBlock:4 length:@(4)];
    __block BOOL successCompletion = header.length == 4;

    UInt8 *bytes = (UInt8*)[header bytes];
    __block UInt8 tagType = 0;
    __block NSString* tagContent;

    if (successCompletion && bytes[0] == 0x46 && bytes[1] == 0x56) {
        tagType = bytes[2];
        UInt8 length = bytes[3];
        NSMutableData *payload = [NSMutableData dataWithLength:length];
        
        UInt8 firstBlock = 5;
        UInt8 block = firstBlock;
        while (length > 0) {
            UInt8 toRead = MIN(4, length);
            NSLog(@"reading block %d bytes %d", block, toRead);
            NSData* replyData = [self syncReadBlock:block length:@(toRead)];
            successCompletion = successCompletion && replyData.length == toRead;
            UInt8 addr = (block - firstBlock) * 4;
            NSLog(@"received bytes %@ for block %d", replyData, block);
            if (replyData.length == toRead) {
                NSRange r = NSMakeRange(addr, replyData.length);
                [payload replaceBytesInRange:r withBytes:replyData.bytes];
            }
            length -= toRead;
            block += 1;
        }
        if (successCompletion) {
            tagContent = [[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding];
        } else {
            NSLog(@"failed to read content properly");
        }
        
        
    } else {
        NSLog(@"not valid tag, skipping");
        successCompletion = NO;
    }


    completion(successCompletion, nfcID, tagType, tagContent);
    
}

- (NSData*)syncReadBlock:(UInt8)block length:(NSNumber*)length {
    
    id v = [self syncSendCommandWithClass:0xFF ins:0xB0 p1:0 p2:block data:nil le:length replyBlock:^id(NSData * _Nullable replyData, UInt16 sw, NSError * _Nullable error) {
        NSLog(@"sync read block %d (length %@) reply data %@",  block, length, replyData);
        if (sw == 0x9000) {
            return replyData;
            
        }
        return nil;
        
    }];
    
    return v;
}


- (BOOL)syncWriteBlock:(UInt8)block data:(NSData*)data {
    if (data.length != 4) {
        NSMutableData *dataToWrite = [NSMutableData data];
        [dataToWrite appendData:data];
        UInt8 pad[1] = {0x2e};
        while (dataToWrite.length < 4) {
            [dataToWrite appendBytes:pad length:1];
        }
        data = dataToWrite;
    }
    id v = [self syncSendCommandWithClass:0xFF ins:0xD6 p1:0 p2:block data:data le:0 replyBlock:^id(NSData * _Nullable replyData, UInt16 sw, NSError * _Nullable error) {
        if (sw == 0x9000) {
            return @(YES);
        }
        return @(NO);
        
    }];
    
    return [v boolValue];
}


- (id)syncSendCommandWithClass:(UInt8)cla ins:(UInt8)ins p1:(UInt8)p1 p2:(UInt8)p2 data:(NSData*)data le:(NSNumber*)le replyBlock:(APDUReplyBlock)replyBlock {
    __block id returnValue = nil;
    dispatch_group_t replyGroup = dispatch_group_create();
    dispatch_group_enter(replyGroup);
    
    NSLog(@"beggingin session");
    [_card beginSessionWithReply:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"in session");
        self.sessionInProgress = success;
        if (success) {
            _card.cla = cla;
            NSLog(@"sending getID command");
            dispatch_group_enter(replyGroup);
            
            [_card sendIns:ins p1:p1 p2:p2 data:data le:le reply:^(NSData * _Nullable replyData, UInt16 sw, NSError * _Nullable error) {
                
                returnValue = replyBlock(replyData, sw, error);
                dispatch_group_leave(replyGroup);
                
                
            }];
            
            
        } else {
            NSLog(@"error beginning session %@", error);
        }
        dispatch_group_leave(replyGroup);
        
    }];
    NSLog(@"waiting for semaphores");
    dispatch_group_wait(replyGroup, DISPATCH_TIME_FOREVER);
    NSLog(@"ending session");
    self.sessionInProgress = NO;
    [_card endSession];
    return returnValue;

}

- (NSData*)getNFCID {
    id value = [self syncSendCommandWithClass:0xFF ins:0xCA p1:0 p2:0 data:nil le:@(0) replyBlock:^id(NSData * _Nullable replyData, UInt16 sw, NSError * _Nullable error) {
        if (sw == 0x9000) {
            return replyData;
        }
        return nil;
    }];
    return value;
    
}

- (NSString*)syncReadString {
    NSData* d = [self syncReadAllData];
    UInt8 *bytes = (UInt8*)[d bytes];
    // header is:
    // 0x46 0x56 [RESERVED] [LENGTH]
    if (!(bytes[0] == 0x46 && bytes[1] == 0x56)) {
        NSLog(@"invalid header");
        return nil;
    }
    UInt8 length = bytes[3];
    NSAssert(length <= d.length - 4, @"header length is larger than what is in the data");
    NSData *newD = [d subdataWithRange:NSMakeRange(4, length)];
    return [[NSString alloc] initWithData:newD encoding:NSUTF8StringEncoding];
}

- (void)syncWriteString:(NSString *)string {
    NSData *payload = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSAssert(payload.length < self.memorySize - 1, @"asked to write more data than fit");
    UInt8 header[4] = {0x46, 0x56, 0x00, (UInt8)payload.length};
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:header length:4];
    [data appendData:payload];
    [self syncWriteAllData:data];
    
    
}

- (NSData*)syncReadAllData {
    NSMutableData *allData = [[NSMutableData alloc] init];
    //naive version
    UInt8 startBlock = 4;
    UInt8 blockCount = self.memorySize / 4 ;
    UInt8 endBlock = startBlock + blockCount - 1;
    for (UInt8 b=startBlock;b<endBlock;b++) {
        NSData *d = [self syncReadBlock:b length:@4];
        NSLog(@"block %d has contents %@", b, d);
        [allData appendData:d];
    }
    return allData;
    
}
- (void)syncWriteAllData:(NSData *)data {
    
    NSAssert(data.length <= self.memorySize, @"asked to write too much data");
    BOOL success = YES;
    UInt8 startBlock = 4;
    UInt8 blockCount = self.memorySize / 4 ;
    UInt8 endBlock = startBlock + blockCount - 1;
    UInt8 idx=0;
    for (UInt8 b=startBlock;b<endBlock;b++) {
        UInt8 l = MIN(4, data.length - idx);
        NSLog(@"writing at idx %d[%d] out of %lu", idx, l, (unsigned long)data.length);
        if (l <= 0) {
            break;
        }
        
        NSData *d = [data subdataWithRange:NSMakeRange(idx, l)];
        NSLog(@"writing to block %d contents %@", b, d);
        success = success && [self syncWriteBlock:b data:d];
        if (!success) {
            NSLog(@"unsuccesful write");
        }
        idx += l;
    }
    
    
}
@end
