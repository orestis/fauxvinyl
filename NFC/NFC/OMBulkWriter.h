//
//  OMBulkWriter.h
//  NFC
//
//  Created by Orestis Markou on 25/6/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OMBulkWriter : NSObject
- (instancetype)initWithAlbums:(NSArray<NSDictionary<NSString*, NSString*>*>*) albums;
@property BOOL finished;
@end
