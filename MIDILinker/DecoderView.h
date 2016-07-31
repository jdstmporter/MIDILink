//
//  DecoderView.h
//  MIDILink
//
//  Created by Julian Porter on 01/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>



@interface DecoderView : NSView <NSTableViewDataSource,NSTableViewDelegate>

@property (weak,nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak,nonatomic) IBOutlet NSTableView *table;
@property (readonly) LinkWrapper *  link;


- (IBAction)action:(id)sender;
- (IBAction)doubleAction:(id)sender;
- (IBAction)resetButton:(NSButton *)sender;
- (IBAction)resetFromMenu:(NSMenuItem *)sender;

- (void)connect:(LinkWrapper *)link;
- (void) disconnect;
- (void) resetDecoder;


@end
