//
//  HRClientSocket.m
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "HRClientSocket.h"
#import <sys/socket.h>
#import <sys/types.h>
#include <netinet/in.h>

@interface  HRClientSocket()

@property (nonatomic,assign) BOOL isValid;


@end

@implementation HRClientSocket

- (void) connectIP:(NSString*) ip port:(NSInteger) port{
    if (self.socket < 0){
        return;
    }
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (connect(self.socket, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        NSLog(@"content error");
        self.isValid = NO;
    } else {
        self.isValid = YES;
    }
}

- (void) sendData:(NSData*) data completionBloack:(void (^)(BOOL isFinish)) completionBloack{
    if (self.socket < 0 || !self.isValid) {
        NSLog(@"error socket");
        if (completionBloack){
            completionBloack(NO);
        }
        return;
    }
    [super sendData:data completionBloack:completionBloack];
}

- (void) recivSoketCompletionBlock:(void (^)(NSData* data)) completionBlock{
    if (self.socket < 0 || !self.isValid) {
        NSLog(@"error socket");
        if (completionBlock){
            completionBlock(nil);
        }
        return;
    }
    [super recivSoketCompletionBlock:completionBlock];
}

@end
