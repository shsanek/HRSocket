//
//  main.m
//  EchoClient
//
//  Created by Alexander Shipin on 05/03/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <HRSocket/HRClientSocket.h>
#define xstr(s) str(s)
#define str(s) @#s


@interface ChatController : NSObject<HRSocketDelegate>

@property (nonatomic,strong) HRClientSocket* clientSocket;
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
    [socket recivSoketCompletionBlock:nil];
}

- (void) discontentSocket:(HRSocket*) socket{
    [self.chatQueue async:^{
        NSLog(@"the user has left the chat ");
    }];
}


@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        HRClientSocket* clientSocket = [[HRClientSocket alloc] initWithReadQueue:[[HRQueue alloc] initWithQueue:dispatch_queue_create("serverout", NULL)]
                                                                      writeQueue:[[HRQueue alloc] initWithQueue:dispatch_queue_create("serverin", NULL)]];
        ChatController* chatController = [[ChatController alloc] init];
        chatController.clientSocket = clientSocket;
        clientSocket.delegate = chatController;
        chatController.chatQueue = [[HRQueue alloc] initWithQueue:dispatch_queue_create("chat", NULL)];
        [clientSocket connectIP:nil port:3300];
        [clientSocket recivSoketCompletionBlock:nil];
        while (1) {
            char mess[1000];
            scanf("%s",mess);
            NSString* string = [NSString stringWithUTF8String:(const char*)mess];
            NSDictionary * dic = @{@"n":@"name",@"m":string};
            [clientSocket sendData:[NSKeyedArchiver archivedDataWithRootObject:dic]
                  completionBloack:nil];
        };
    }
    return 0;
}

