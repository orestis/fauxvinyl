//
//  NFCExplorer.m
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//



#import "NFCExplorer.h"



NSString* stateString(TKSmartCardSlotState);

NSString* stateString(TKSmartCardSlotState state) {
    switch (state) {
        case TKSmartCardSlotStateEmpty:
            return @"Empty";
            break;
        case TKSmartCardSlotStateMissing:
            return @"Missing";
            break;
        case TKSmartCardSlotStateMuteCard:
            return @"MuteCard";
            break;
        case TKSmartCardSlotStateProbing:
            return @"Probing";
            break;
        case TKSmartCardSlotStateValidCard:
            return @"Valid Card";
            break;
        default:
            return @"error";
            break;
    }
    return @"bug";
}


@interface OMSmartCardSlotStateTransformer : NSValueTransformer

@end

@implementation OMSmartCardSlotStateTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    TKSmartCardSlotState state = [value integerValue];
    return stateString(state);
}

@end

@interface OMNSIntegerTransformer : NSValueTransformer
@end

@implementation OMNSIntegerTransformer

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return value;
}

@end

@interface OMNSDataTransformer : NSValueTransformer
@end

@implementation OMNSDataTransformer

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [value description];
}

@end

@interface NFCExplorer ()

@property (nonatomic, retain) TKSmartCardSlotManager * mngr;
@property (readwrite) TKSmartCardSlot* reader;
@property (nonatomic, readwrite) NFCTagWrapper* currentTag;


@end

@implementation NFCExplorer

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mngr = [TKSmartCardSlotManager defaultManager];
    assert(self.mngr);
    
    //
    [self.mngr addObserver:self forKeyPath:@"slotNames" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];

    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (object == self.mngr) {
        NSLog(@"(Re)Scanning Slots: %@",[self.mngr slotNames]);
        

        
        for(NSString *slotName in [_mngr slotNames]) {
            NSLog(@"found slot %@", slotName);
            [_mngr getSlotWithName:slotName reply:^(TKSmartCardSlot *slot) {
                self.reader = slot;
                [self prepareReader];
            }];
        };
    } else if (object == self.reader) {
        NSLog(@"state %@", stateString(self.reader.state));
        if (self.reader.state == TKSmartCardSlotStateValidCard) {
            TKSmartCard *card = [self.reader makeSmartCard];

//            NSLog(@"ATR bytes %@ historical bytes %@", self.reader.ATR.bytes, self.reader.ATR.historicalBytes);
//            self.reader.ATR.

            self.currentTag = [[NFCTagWrapper alloc] initWithSmartCard:card];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [self.currentTag tryFastReadWithCompletionBlock:^(BOOL success, NSData* nfcID, UInt8 tagType, NSString *tagContent) {
                    NSLog(@"FAST READ FINISHED SUCCeSS? %d, type %d, content %@", success, tagType, tagContent);
                    if (success) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSLog(@"posting notification");
                            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NFCTagRead" object:nil userInfo:@{@"type": @(tagType), @"content": tagContent} deliverImmediately:YES];
    
                        });

                    }
                }];
                [self.currentTag preread];

            });
            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSString *s = [self.currentTag syncReadString];
//                NSLog(@"prepreading string %@", s);
//                if (s != nil) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSLog(@"posting notification");
//                        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NFCTagRead" object:nil userInfo:@{@"tagID": self.currentTag.nfcID, @"type": @"spotify", @"uri": s}];
//                        
//                    });
//                    
//                }
//            });
//            NSLog(@"created currentTag %@", self.currentTag);
        } else {
            NSLog(@"lost currentTag %@", self.currentTag);
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"NFCTagRemoved" object:nil userInfo:@{}];
            self.currentTag = nil;

        }
    }

}


- (IBAction)readDataBlock:(id)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSLog(@"block %@ length %@", self.blockNumber, self.byteCount);
        UInt8 block = self.blockNumber.intValue;
        
        NSNumber* length = [NSNumber numberWithInt:[self.byteCount intValue]];
        NSData *data = [self.currentTag syncReadBlock:block length:length];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data != nil) {
                [self.blockContent setStringValue:data.description];
                NSString *ascii = [NSString stringWithCString:data.bytes encoding:NSASCIIStringEncoding];
                [self.asciiContent setStringValue:ascii];
            } else {
                [self.blockContent setStringValue:@"<ERROR>"];
                [self.asciiContent setStringValue:@"<ERROR>"];
            }
        });
    });

}



- (IBAction)writeDataBlock:(id)sender {
    NSLog(@"block %@ length %@", self.blockNumber, self.byteCount);
    UInt8 block = self.blockNumber.intValue;
    
    NSNumber* length = [NSNumber numberWithInt:[self.byteCount intValue]];

    NSString *ascii = self.asciiContent.stringValue;
    NSData *d = [ascii dataUsingEncoding:NSASCIIStringEncoding];
    if (d.length != length.intValue) {
        [self.blockContent setStringValue:@"<BAD LENGTH>"];
        [self.asciiContent setStringValue:@"<BAD LENGTH>"];
        return;
    }

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        BOOL success = [self.currentTag syncWriteBlock:block data:d];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self readDataBlock:self];
            } else {
                [self.blockContent setStringValue:@"<ERROR>"];
                [self.asciiContent setStringValue:@"<ERROR>"];
            }

        });
    });
    


}

- (IBAction)readText:(id)sender {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSString *s = [self.currentTag syncReadString];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (s == nil) {
                [self.allContent setStringValue:@""];
            } else {
                [self.allContent setStringValue:s];
            }
        });
    });

}
- (IBAction)writeText:(id)sender {
    NSString *s = self.allContent.stringValue;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        [self.currentTag syncWriteString:s];
    });
}





- (void)prepareReader {
    [self.reader addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];
    
    NSLog(@"Slot:    %@",self.reader);
    NSLog(@"  name:  %@",self.reader.name);
    NSLog(@"  state: %@",stateString(self.reader.state) );

}


@end
