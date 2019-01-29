//  Created by Nikola Lajic on 12/10/18.
//  Copyright © 2018 Nikola Lajic. All rights reserved.

#import "ViewController.h"
@import Instana;

@interface ViewController ()
@property (strong) InstanaRemoteCallMarker *marker;
@end

@interface ViewController (URLSession) <NSURLSessionTaskDelegate, NSURLSessionDelegate>
@end

#pragma mark -

@implementation ViewController

- (IBAction)onTapCrash:(id)sender {
    @throw NSInternalInconsistencyException;
//    int* p = 0;
//    *p = 0;
}

- (IBAction)onTapUrlRequest:(id)sender {
    // custom event
    [Instana.events submitEvent:[[InstanaCustomEvent alloc] initWithName:@"manual evenet" timestamp:[[NSDate new] timeIntervalSince1970] duration:1.5]];
    
    // shared session
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.apple.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"[DemoObjC] Finished shared session task (apple)");
    }] resume];
    
    // custom session
    NSURLSessionConfiguration *customConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [Instana.remoteCallInstrumentation installIn:customConfig];
    customConfig.allowsCellularAccess = false;
    [[[NSURLSession sessionWithConfiguration:customConfig] dataTaskWithURL:[NSURL URLWithString:@"http://www.google.com/"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"[DemoObjC] Finished custom session task (google)");
    }] resume];
    
    // manual tracking
    NSURLSessionConfiguration *ephemeralConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"https://www.microsoft.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.marker = [Instana.remoteCallInstrumentation markCallTo:url.absoluteString method:@"GET"];
    [[[NSURLSession sessionWithConfiguration:ephemeralConfig delegate:self delegateQueue:nil] dataTaskWithRequest:request] resume];
    
    // cancelled request
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://www.yahoo.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"[DemoObjC] Finished cancelled task (yahoo)");
    }];
    [task resume];
    [task cancel];
}

@end

#pragma mark -

@implementation ViewController (URLSession)

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) [self.marker endedWithError:error];
    else [self.marker endedWithResponseCode:200];
    NSLog(@"[DemoObjC] Finished manually tracked delegated task (microsoft)");
}

@end