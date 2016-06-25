//
//  NFCController.h
//  NFC
//
//  Created by Orestis Markou on 19/3/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NFCControllerDelegate <NSObject>

- (void)readCardWithID:(NSString*)cardID andData:(NSData*)data;

@end





@end
