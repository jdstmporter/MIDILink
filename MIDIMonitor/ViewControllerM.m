//
//  ViewController.m
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "ViewControllerM.h"

@interface ScanViewController ()

@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scanForEndpoints:nil];
}

- (IBAction)scanForEndpoints:(NSButton *)sender {
    [self.endpoints scan];
}

- (IBAction)monitorEndpoint:(NSButton *)sender {
    EndpointWrapper *endpoint=[self.endpoints selected];
    NSLog(@"Decoding %@ . . .",endpoint);
    [self.decoder start:endpoint];
}

- (void)monitorENdpointFromMenu:(NSMenuItem *)sender {
    [self monitorEndpoint:nil];
}


- (IBAction)scanForEndpointsFromMenu:(NSMenuItem *)sender {
    [self.endpoints scan];
}

- (void)drawerDidOpen:(NSNotification *)notification {
    [self.injector reset];
}

@end
