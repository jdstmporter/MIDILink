//
//  ViewController.m
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "InjectViewController.h"

@interface InjectViewController ()

@property (strong,nonatomic) MIDIInjector *client;
@property (atomic) MIDIUniqueID uid;

@end

@implementation InjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scanForEndpoints:nil];
    [self.injector reset:nil];
    self.client=nil;
    self.uid=0;
}

- (void)dealloc {
    if(self.client) [self.client disconnect];
}

- (IBAction)scanForEndpoints:(NSButton *)sender {
    [self.endpoints scan];
}



- (IBAction)scanForEndpointsFromMenu:(NSMenuItem *)sender {
    [self.endpoints scan];
}

- (void)injectPacket:(NSButton *)sender {
    MIDIEndPointDescription *endpoint=[self.endpoints selected];
    if(!endpoint) return;
    
    if(self.client && self.uid!=endpoint.uid) {
        [self.client disconnect];
        self.client=nil;
    }
    if(!self.client) {
        self.uid=endpoint.uid;
        self.client=[[MIDIInjector alloc] initWithName:@"Injection"];
        [self.client connect:endpoint.thing];
    }
    
    MIDIBuilder *builder=[self.injector message];
    MIDIPacketList list=[builder getPacketList];
    [self.client inject:&list];
}



@end
