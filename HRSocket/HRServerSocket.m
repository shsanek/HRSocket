//
//  HRServerSoket.m
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "HRServerSocket.h"
#import <sys/socket.h>
#import <sys/types.h>
#include <netinet/in.h>

@interface HRServerSocket ()<HRSocketDelegate>

@property (nonatomic,strong,readonly) NSMutableArray<HRQueue*>* freeQueue;
@property (nonatomic,strong,readonly) NSMutableDictionary<NSNumber*,NSArray<HRQueue*>*>* lockQueue;
@property (nonatomic,strong,readonly) NSMutableArray<HRSocket*>* clientSockets;
@property (nonatomic,strong,readonly) HRQueue* listernQueue;
@property (nonatomic,assign) BOOL isValid;

@end

@implementation HRServerSocket

- (instancetype)init {
    self = [super init];
    if (self) {
        [self serverLoad];
    }
    return self;
}

- (instancetype)initWithReadQueue:(HRQueue *)readQueue writeQueue:(HRQueue *)writeQueue{
    self = [super initWithReadQueue:readQueue writeQueue:writeQueue];
    if (self) {
        [self serverLoad];
    }
    return self;
}

- (instancetype)initWithSocket:(int)socket readQueue:(HRQueue *)readQueue writeQueue:(HRQueue *)writeQueue{
    self = [super initWithSocket:socket readQueue:readQueue writeQueue:writeQueue];
    if (self) {
        [self serverLoad];
    }
    return self;
}

- (void) serverLoad{
    NSString* identifier = [NSString stringWithFormat:@"queue%@",[HRServerSocket nextIndex]];
    _listernQueue = [[HRQueue alloc] initWithQueue:dispatch_queue_create([identifier UTF8String], NULL)];
    _freeQueue = [NSMutableArray new];
    _clientSockets = [NSMutableArray new];
    _lockQueue = [NSMutableDictionary new];
}

+ (NSString*) nextIndex{
    static NSUInteger index;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        index = 0;
    });
    index++;
    NSString* string = [NSString stringWithFormat:@"HRSocketServerBackgroundQueueNumber%lu",(unsigned long)index];
    return string;
}

- (NSArray<HRSocket *> *)sockets{
    return self.clientSockets;
}

- (void) addedSocket:(int) socketNumber{
    __block HRSocket* socket = nil;
    __block HRQueue* readQueue = nil;
    __block HRQueue* writeQueue = nil;
    __weak typeof(self) weakSelf = self;
    if (weakSelf.freeQueue.count) {
        readQueue = weakSelf.freeQueue.lastObject;
        [weakSelf.freeQueue removeLastObject];
    } else{
        readQueue = [[HRQueue alloc] initWithQueue:dispatch_queue_create([HRServerSocket nextIndex].UTF8String, NULL)];
    }
    if (weakSelf.freeQueue.count) {
        writeQueue = weakSelf.freeQueue.lastObject;
        [weakSelf.freeQueue removeLastObject];
    } else{
        writeQueue = [[HRQueue alloc] initWithQueue:dispatch_queue_create([HRServerSocket nextIndex].UTF8String, NULL)];
    }
    [weakSelf.lockQueue setObject:@[writeQueue,readQueue] forKey:@(socketNumber)];
    socket = [self socketCreate:socketNumber readQueue:readQueue writeQueue:writeQueue];
    [weakSelf.clientSockets addObject:socket];
    
    socket.delegate = self;
    [self.delegate contentSocket:socket];
    [self loopSocket:socket];
}

- (HRSocket*) socketCreate:(int) socket readQueue:(HRQueue*) readQueue writeQueue:(HRQueue*) writeQueue{
    return [[HRSocket alloc] initWithSocket:socket readQueue:readQueue writeQueue:writeQueue];
}

- (void) loopSocket:(HRSocket*) socket{
    __block BOOL isData;
    __weak typeof(self) weakSelf = self;
    [socket recivSoketCompletionBlock:^(NSData *data) {
        isData = !!data;
        if (isData) {
            [weakSelf endSocket:socket];
        } else {
            [weakSelf.readQueue async:^{
                [weakSelf loopSocket:socket];
            }];
        }
    }];
}

- (void) endSocket:(HRSocket*) socket{
    [self.delegate discontentSocket:socket];
    __weak typeof(self) weakSelf = self;
    [self.readQueue sync:^{
        HRQueue* queue = self.lockQueue[@(socket.socket)][0];
        [weakSelf.freeQueue addObject:queue];
        queue = weakSelf.lockQueue[@(socket.socket)][1];
        [weakSelf.freeQueue addObject:queue];
        [weakSelf.lockQueue removeObjectForKey:@(socket.socket)];
        [weakSelf.freeQueue addObject:queue];
        [weakSelf.clientSockets removeObject:socket];
    }];
}

- (void) loopListen{
    __weak typeof(self) weakSelf = self;
    [self.listernQueue async:^{
        int sock = accept(weakSelf.socket, NULL, NULL);
        if(sock < 0){
            NSLog(@"warning:socket identifier < 0");
            return;
        }
        [weakSelf.readQueue sync:^{
            [weakSelf addedSocket:sock];
        }];
        [weakSelf loopListen];
    }];
}

- (void) startListenNumberOfContent:(NSInteger) numberOfContent{
    if (self.socket < 0 || !self.isValid) {
        NSLog(@"error socket");
        return;
    }
    listen(self.socket, (int)numberOfContent);
    [self loopListen];
}

- (void)sendData:(NSData *)data completionBloack:(void (^)(BOOL))completionBloack{
    if (self.socket < 0 || !self.isValid) {
        NSLog(@"error socket");
        if (completionBloack){
            completionBloack(NO);
        }
        return;
    }
    [self.writeQueue async:^{
        __block BOOL isData = YES;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        int k = 0;
        for (HRSocket* soc in self.sockets) {
            [soc sendData:data completionBloack:^(BOOL isFinish) {
                isData = isData && isFinish;
                dispatch_semaphore_signal(semaphore);
            }];
            k ++;
        }
        for (int i = 0; i < k; i++){
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if (completionBloack) {
            completionBloack(isData);
        }
    }];
}

- (void)startServerWithPort:(NSInteger)port maxContent:(NSInteger) numberOfContent{
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    if (bind(self.socket, (struct sockaddr *)&addr, sizeof(addr)) < 0  ){
        NSLog(@"server error");
        self.isValid = NO;
    } else {
        self.isValid = YES;
    }
    [self startListenNumberOfContent:numberOfContent];
}


#pragma mark - HRSocketDelegate
- (void)contentSocket:(HRSocket *)socket {
    [self.delegate contentSocket:socket];
}

- (void) socket:(HRSocket*) socket didRecivData:(NSData*) data{
    [self.delegate socket:socket didRecivData:data];
}

- (void) discontentSocket:(HRSocket*) socket{
    [self.delegate discontentSocket:socket];
}


@end
