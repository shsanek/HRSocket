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

- (u_int32_t) ipFromString:(NSString*) string{
    NSArray* component = [ string componentsSeparatedByString:@"."];
    NSAssert(component.count == 4, @"incorect ip addres");
    u_char result[4] = {0,0,0,0};
    int i = 0;
    for (NSString* com in component){
        NSInteger a = [com integerValue];
        result[i] = a;
    }
    u_int32_t numberResult = (u_int32_t)(result);
    return numberResult;
}

- (void) connectIP:(NSString*) ip port:(NSInteger) port{
    if (self.socket < 0){
        return;
    }
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    if (!ip) {
        addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    } else {
        addr.sin_addr.s_addr = htonl([self ipFromString:ip]);
    }
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
