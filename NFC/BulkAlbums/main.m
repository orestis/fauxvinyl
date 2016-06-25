//
//  main.m
//  BulkAlbums
//
//  Created by Orestis Markou on 25/6/16.
//  Copyright © 2016 Orestis Markou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OMBulkWriter.h"

NSArray<NSString*>* readAlbums(NSString* filename) {
    NSError *error;
    NSString* contents = [NSString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:&error];
    if (error != nil) {
        NSLog(@"error reading file: %@", error);
        return nil;
    }
    NSArray<NSString*>* array = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] ;
    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", @""]];
    return array;
}

NSArray<NSDictionary<NSString*, NSString*>*>* fetchAlbumInfo(NSArray<NSString*>* albums) {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *delegateFreeSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSMutableArray *albumInfo = [NSMutableArray array];
    NSString *base = @"https://api.spotify.com/v1/albums/";
//    dispatch_group_t requestGroup = dispatch_group_create();
//    dispatch_group_enter(requestGroup);

    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    __block int pendingRequests = 0;

    for (NSString* albumURI in albums ) {
        NSString *albumID = [albumURI stringByReplacingOccurrencesOfString:@"spotify:album:" withString:@""];
        NSString *urlString = [NSString stringWithFormat:@"%@%@", base, albumID];
        NSURL *url = [NSURL URLWithString:urlString];
//        NSLog(@"REQ: %@", albumURI);
        pendingRequests++;
        [[delegateFreeSession dataTaskWithURL: url
                            completionHandler:^(NSData *data, NSURLResponse *response,
                                                NSError *error) {
//                                NSLog(@"RESP: %@", albumURI);
                                if (error != nil) {
                                    NSLog(@"Got response %@ with error %@.\n", response, error);
                                } else {
                                    NSError *jsonError;
                                    id spotifyInfo = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                    if (jsonError != nil) {
                                        NSLog(@"error decoding data %@",  data);
                                        return;
                                    } else {
                                        NSArray *artists = spotifyInfo[@"artists"];
                                        NSMutableArray *artistsNames = [NSMutableArray array];
                                        [artists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            [artistsNames addObject:obj[@"name"]];
                                        }];
                                        NSDictionary *info = @{
                                                               @"name": [NSString stringWithFormat: @"%@ - %@", [artistsNames componentsJoinedByString:@", "], spotifyInfo[@"name"]],
                                                               @"uri": albumURI
                                                               
                                                               };
                                        [albumInfo addObject:info];

                                    }
                                }
//                                dispatch_group_leave(requestGroup);
                                pendingRequests--;
                                
                                
                            }] resume];

    }
    
    while (pendingRequests > 0 && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]]);

    
    return albumInfo;
    
}





int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...

        NSLog(@"Hello, World!");
        NSLog(@"argc %d", argc);
        if (argc >= 2) {
            NSString* albumsFile = [NSString stringWithUTF8String: argv[1]];
            NSLog(@"reading data from %@", albumsFile);
            NSArray<NSString*>* albums = readAlbums(albumsFile);
            NSArray* albumInfo = fetchAlbumInfo(albums);
            NSLog(@"albumInfo %@", albumInfo);
            OMBulkWriter *writer = [[OMBulkWriter alloc] initWithAlbums:albumInfo];
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            while (!writer.finished && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:2]]);

        }
    }
    return 0;
}
