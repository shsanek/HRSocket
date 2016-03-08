//
//  HRQueue.h
//  HRLog
//
//  Created by Alexander Shipin on 28/02/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HRQueue : NSObject

@property (nonatomic,strong,readonly) dispatch_queue_t queue;

- (instancetype) initWithQueue:(dispatch_queue_t) queue;

- (void) sync:(void (^)()) block;
- (void) async:(void (^)()) block;

@end
