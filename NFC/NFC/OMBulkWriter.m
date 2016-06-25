//
//  OMBulkWriter.m
//  NFC
//
//  Created by Orestis Markou on 25/6/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import "OMBulkWriter.h"
@import CryptoTokenKit;
#import "NFCTagWrapper.h"


@interface OMBulkWriter ()
@property (nonatomic, retain) TKSmartCardSlotManager * mngr;
@property (readwrite) TKSmartCardSlot* reader;
@property (nonatomic, readwrite) NFCTagWrapper* currentTag;

@end

@implementation OMBulkWriter {
    NSArray<NSDictionary<NSString*, NSString*>*> *_albums;
    NSUInteger currentAlbum;
    BOOL ready;
}



- (instancetype)initWithAlbums:(NSArray<NSDictionary<NSString*, NSString*>*>*) albums
{
    self = [super init];
    if (self) {
        _albums = albums;
        currentAlbum = 0;
        self.finished = NO;
        self.mngr = [TKSmartCardSlotManager defaultManager];
        assert(self.mngr);
        ready = NO;
        [self.mngr addObserver:self forKeyPath:@"slotNames" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];
        
    }
    return self;
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
                [self printWaitingHeader];
            }];
        };
    } else if (object == self.reader) {
        if (self.reader.state == TKSmartCardSlotStateValidCard) {
            ready = YES;
            TKSmartCard *card = [self.reader makeSmartCard];
            self.currentTag = [[NFCTagWrapper alloc] initWithSmartCard:card];
            [self printInitHeader];
            [self.currentTag addObserver:self forKeyPath:@"memorySize" options:NSKeyValueObservingOptionNew context:nil];
            [self.currentTag preread];
            
            
        } else {
//            NSLog(@"lost currentTag %@", self.currentTag);
            [self.currentTag removeObserver:self forKeyPath:@"memorySize"];
            self.currentTag = nil;
            if (ready) {
                if (currentAlbum <= _albums.count - 1) {
                    [self printWaitingHeader];
                } else {
                    printf("FINISHED\n");
                    self.finished = YES;
                }
            }
            
        }
    } else if (object == self.currentTag && [keyPath isEqualToString:@"memorySize"]) {
        // TAG is ready to write
        
        // TODO write
        NSDictionary *albumInfo = _albums[currentAlbum];
        NSString *uri = albumInfo[@"uri"];
//        NSLog(@"should write %@", uri);
        [self printWritingHeader];
        [self.currentTag syncWriteString:uri];
        NSString *contents = [self.currentTag syncReadString];
        while (![contents isEqualToString:uri]) {
            [self printWritingHeader];
            [self.currentTag syncWriteString:uri];
            contents = [self.currentTag syncReadString];
        }
        
        [self printRemoveHeader];
        currentAlbum ++;

        
        
    }
    
}
- (void)printWritingHeader {
    NSDictionary *albumInfo = _albums[currentAlbum];
    printf(">%ld Writing %s ...\n", currentAlbum, [albumInfo[@"uri"] cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)printRemoveHeader {
    printf(">%ld Remove tag...\n", currentAlbum);
}

- (void)printInitHeader {
    printf(">%ld Reading tag...\n", currentAlbum);
}


- (void)printWaitingHeader {
    NSDictionary *albumInfo = _albums[currentAlbum];
    printf(">%ld %s ...\n", currentAlbum, [albumInfo[@"name"] cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)prepareReader {
    [self.reader addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial context:nil];
    
    NSLog(@"Slot:    %@",self.reader);
    NSLog(@"  name:  %@",self.reader.name);
//    NSLog(@"  state: %@",stateString(self.reader.state) );
    
}


@end
