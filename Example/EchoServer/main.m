//
//  main.m
//  EchoServer
//
//  Created by Alexander Shipin on 05/03/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HRSocket/HRServerSocket.h>


@interface ChatController : NSObject<HRSocketDelegate>

@property (nonatomic,strong) HRServerSocket* serverSocket;
@property (nonatomic,strong) HRQueue* chatQueue;

@end

@implementation ChatController

- (void) contentSocket:(HRSocket*) socket{
    [self.chatQueue async:^{
        NSLog(@"new user");
    }];
    
}

- (void) socket:(HRSocket*) socket didRecivData:(NSData*) data{
    NSDictionary* dictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [self.chatQueue async:^{
        NSLog(@"%@:%@",dictionary[@"n"],dictionary[@"m"]);
    }];
    [self.serverSocket sendData:data completionBloack:nil];
}

- (void) discontentSocket:(HRSocket*) socket{
    [self.chatQueue async:^{
        NSLog(@"the user has left the chat ");
    }];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        HRServerSocket* serverSocket = [[HRServerSocket alloc] initWithReadQueue:[[HRQueue alloc] initWithQueue:dispatch_queue_create("serverout", NULL)]
                                                                      writeQueue:[[HRQueue alloc] initWithQueue:dispatch_queue_create("serverin", NULL)]];
        ChatController* chatController = [[ChatController alloc] init];
        chatController.serverSocket = serverSocket;
        serverSocket.delegate = chatController;
        chatController.chatQueue = [[HRQueue alloc] initWithQueue:dispatch_queue_create("chat", NULL)];
        [serverSocket startServerWithPort:3300 maxContent:10];
        while (1) {};
    }
    return 0;
}
