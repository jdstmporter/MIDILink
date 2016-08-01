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
    [self.injector reset:nil];
}

- (IBAction)scanForEndpoints:(NSButton *)sender {
    [self.endpoints scan];
}



- (IBAction)scanForEndpointsFromMenu:(NSMenuItem *)sender {
    [self.endpoints scan];
}

- (void)injectPacket:(NSButton *)sender {
    EndpointWrapper *endpoint=[self.endpoints selected];
    MIDIBuilder *builder=[self.injector message];
    
    if(endpoint) {
        MIDIInjector *injector=[[MIDIInjector alloc] initWithName:@"Injection"];
        [injector connect:[endpoint.endpoint thing]];
        MIDIPacketList list=[builder getPacketList];
        [injector inject:&list];
        [injector disconnect];
    }
}



@end
