//
//  AppDelegate.m
//  SErver
//
//  Created by Alexander Shipin on 14/04/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Create server
//    GCDWebServer *_webServer = [[GCDWebServer alloc] init];
//    NSError* error = nil;
//    NSString* string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]
//                                                 encoding:(NSUTF8StringEncoding)
//                                                    error:&error];
//    // Add a handler to respond to GET requests on any URL
//    [_webServer addDefaultHandlerForMethod:@"GET"
//                              requestClass:[GCDWebServerRequest class]
//                              processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
//                                  
//                                  return [GCDWebServerDataResponse responseWithHTML:string];
//                                  
//                              }];
//    
//    // Start server on port 8080
//    //[_webServer startWithPort:8080 bonjourName:nil];
//    NSLog(@"Visit %@ in your web browser", _webServer.serverURL);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
