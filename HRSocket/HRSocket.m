//
//  HRSocket.m
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "HRSocket.h"
#import <sys/socket.h>

@implementation HRSocket

- (instancetype)init {
    self = [super init];
    if (self) {
        _socket = socket(AF_INET, SOCK_STREAM, 0);
        if (_socket < 0) {
            NSLog( @"not create socket");
        }
        _readQueue = [[HRQueue alloc] initWithQueue:dispatch_get_main_queue()];
        _writeQueue = _readQueue;
    }
    return self;
}

- (instancetype) initWithReadQueue:(HRQueue *)readQueue writeQueue:(HRQueue *)writeQueue{
    self = [super init];
    if (self) {
        _socket = socket(AF_INET, SOCK_STREAM, 0);
        if (_socket < 0) {
            NSLog( @"not create socket");
        }
        _readQueue = readQueue;
        _writeQueue = writeQueue;
    }
    return self;
}

- (instancetype) initWithSocket:(int) socket readQueue:(HRQueue *)readQueue writeQueue:(HRQueue *)writeQueue{
    self = [super init];
    if (self) {
        _socket = socket;
        if (_socket < 0) {
            NSLog( @"not create socket");
        }
        _readQueue = readQueue;
        _writeQueue = writeQueue;
    }
    return self;
}

- (void)recivSoketCompletionBlock:(void (^)(NSData *))completionBlock{
    [self.readQueue async:^{
        [self syncRecivSoketCompletionBlock:completionBlock];
    }];
}

- (void) syncRecivSoketCompletionBlock:(void (^)(NSData *))completionBlock{
    char* buf = malloc(sizeof(UInt32));
    int bytes_read = 0;
    while (1) {
        ssize_t n = recv(_socket, buf + bytes_read, sizeof(UInt32) - bytes_read, 0);
        if (n < 0) {
            if (completionBlock) {
                completionBlock(nil);
            }
            return;
        }
        if (n > 0) {
            bytes_read += n;
        }
        if (bytes_read == sizeof(UInt32)) {
            break;
        }
    }
    
    UInt32 len = *((UInt32*)buf);
    free(buf);
    buf = malloc(len);
    bytes_read = 0;
    while(1)
    {
        ssize_t n = recv(_socket, buf + bytes_read, len - bytes_read, 0);
        if (n < 0) {
            free(buf);
            if (completionBlock) {
                completionBlock(nil);
            }
            return;
        }
        if (n > 0) {
            bytes_read += n;
        }
        if (bytes_read == len) {
            break;
        }
    }
    NSData* data = [[NSData alloc] initWithBytes:buf length:len];
    free(buf);
    [self.delegate socket:self didRecivData:data];
    if (completionBlock) {
        completionBlock(nil);
    }
    return;
}

- (NSUInteger) _sendData:(char*) buf len:(NSUInteger) len{
    int total = 0;
    ssize_t n = 0;
    
    while(total < len)
    {
        n = send(_socket, buf+total, len-total, 0);
        if(n == -1) { break; }
        total += n;
    }
    
    return (n==-1 ? -1 : total);
}

- (void)sendData:(NSData *)data completionBloack:(void (^)(BOOL))completionBloack{
    [self.writeQueue async:^{
        NSUInteger total = 0;
        char* buf = (char*)data.bytes;
        UInt32 len = (UInt32)data.length;
        total = [self _sendData:(void*)&len len:sizeof(len)];
        if (total != -1) {
            total = [self _sendData:buf len:len];
        }
        if (completionBloack) {
            if (total == -1) {
                completionBloack(NO);
            } else {
                completionBloack(YES);
            }
        }
    }];
}

@end
