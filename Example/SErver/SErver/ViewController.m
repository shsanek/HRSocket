//
//  ViewController.m
//  SErver
//
//  Created by Alexander Shipin on 14/04/16.
//  Copyright © 2016 Alexander Shipin. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (nonatomic,strong) IBOutlet UIWebView* webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *nsUrl = [NSURL URLWithString:@"http://localhost:8080/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:nsUrl
                                             cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                         timeoutInterval:30];
    //[self.webView loadRequest:request];
    NSError* error = nil;
    NSString* string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]
                                                 encoding:(NSUTF8StringEncoding)
                                                    error:&error];
    [self.webView loadHTMLString:string baseURL:[NSURL URLWithString:@"http://localhost"]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
