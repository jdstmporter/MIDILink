//
//  EndPointList.h
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>


@interface EndPointView : NSView <NSTableViewDelegate,NSTableViewDataSource>

@property (strong) NSArray *endpoints;
@property NSInteger endpoint;

@property (weak) IBOutlet NSTableView *view;

- (IBAction) action:(NSTableView *)sender;
- (IBAction) doubleAction:(NSTableView *)sender;

- (EndpointWrapper *)selected;

- (void) scan;



@end
