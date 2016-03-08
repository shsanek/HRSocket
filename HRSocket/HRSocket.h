//
//  HRSocket.h
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRQueue.h"

@class HRSocket;

@protocol HRSocketDelegate <NSObject>

- (void) contentSocket:(HRSocket*) socket;
- (void) socket:(HRSocket*) socket didRecivData:(NSData*) data;
- (void) discontentSocket:(HRSocket*) socket;

@end

@interface HRSocket : NSObject

@property (nonatomic,weak) id<HRSocketDelegate> delegate;
@property (nonatomic,assign,readonly) int socket;
@property (nonatomic,strong,readonly) HRQueue* writeQueue;
@property (nonatomic,strong,readonly) HRQueue* readQueue;

- (instancetype) initWithSocket:(int) socket readQueue:(HRQueue*) readQueue writeQueue:(HRQueue*) writeQueue;
- (instancetype) initWithReadQueue:(HRQueue*) readQueue writeQueue:(HRQueue*) writeQueue;

- (void) sendData:(NSData*) data completionBloack:(void (^)(BOOL isFinish)) completionBloack;
- (void) recivSoketCompletionBlock:(void (^)(NSData* data)) completionBlock;

@end



