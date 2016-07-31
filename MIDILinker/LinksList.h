//
//  LinksList.h
//  MIDILink
//
//  Created by Julian Porter on 29/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>

@interface LinksList : NSView <NSTableViewDelegate,NSTableViewDataSource,NSDrawerDelegate>


@property (strong) IBOutlet NSTableView *linksView;
@property (weak) IBOutlet NSDrawer *decoderDrawer;


- (IBAction) action:(NSTableView *)sender;
- (IBAction) doubleAction:(NSTableView *)sender;

- (void)createLinkFrom:(MIDIThing *)source to:(MIDIThing*)destination;
- (void)unlink;
- (void)unlinkAll;

@end
