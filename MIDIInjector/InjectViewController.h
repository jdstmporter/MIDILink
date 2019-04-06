//
//  ViewController.h
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>
#import "InjectEndPointList.h"
#import "Decoder.h"
#import "InjectorView.h"

@interface InjectViewController : NSViewController <NSDrawerDelegate>

@property (weak) IBOutlet InjectEndPointView *endpoints;
@property (weak) IBOutlet InjectorView *injector;

- (IBAction)scanForEndpoints:(NSButton *)sender;
- (IBAction)scanForEndpointsFromMenu:(NSMenuItem *)sender;

- (IBAction)injectPacket:(NSButton *)sender;


@end
