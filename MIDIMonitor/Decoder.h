//
//  Decoder.h
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MIDIManager/MIDIManager.h>



@interface Decoder : NSView <NSTableViewDataSource,NSTableViewDelegate>

@property (weak,nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak,nonatomic) IBOutlet NSTableView *table;
@property (readonly) EndpointWrapper *  endpoint;
@property (strong,nonatomic) NSURL *filePath;


- (IBAction)save:(id)sender;
- (IBAction)saveAs:(id)sender;

- (IBAction)action:(id)sender;
- (IBAction)doubleAction:(id)sender;
- (IBAction)resetButton:(NSButton *)sender;
- (IBAction)resetFromMenu:(NSMenuItem *)sender;
- (IBAction)stopButton:(NSButton *)sender;
- (IBAction)stopButtonFromMenu:(NSMenuItem *)sender;

- (void)start:(EndpointWrapper *)endpoint;
//- (void) disconnect;
- (void) resetDecoder;

- (void)doSomething;


@end