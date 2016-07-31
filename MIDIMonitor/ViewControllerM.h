//
//  ViewController.h
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>
#import "EndPointList.h"
#import "Decoder.h"
#import "InjectorView.h"

@interface ScanViewController : NSViewController <NSDrawerDelegate>

@property (weak) IBOutlet EndPointView *endpoints;
@property (weak) IBOutlet Decoder *decoder;
@property (weak) IBOutlet InjectorView *injector;

- (IBAction)scanForEndpoints:(NSButton *)sender;
- (IBAction)scanForEndpointsFromMenu:(NSMenuItem *)sender;
- (IBAction)monitorEndpoint:(NSButton *)sender;
- (IBAction)monitorENdpointFromMenu:(NSMenuItem *)sender;

@end
