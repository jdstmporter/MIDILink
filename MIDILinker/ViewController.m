//
//  ViewController.m
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self scan:nil];
}

- (IBAction)scan:(NSButton *)sender {
    [self.endpoints scan];
}

- (IBAction)link:(NSButton *)sender {
    EndPointPair *pair=[self.endpoints linkablePair];
    [self.links createLinkFrom:pair.source to:pair.destination];
}

- (IBAction)scasnFromMenu:(NSMenuItem *)sender {
    [self.endpoints scan];
}

- (IBAction)unlink:(NSButton *)sender {
    [self.links unlink];
}

- (void)unlinkAll {
    [self.links unlinkAll];
}
@end
