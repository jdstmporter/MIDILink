//
//  Decoder.m
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "Decoder.h"



@interface Decoder ()

@property (strong,nonatomic)  EndpointWrapper * _Nullable endpoint;
@property (readonly)  MIDIDecoder * _Nullable decoder;
@end


@implementation Decoder

- (void) initialise {
    self.endpoint=nil;
    self.filePath=nil;
}

- (instancetype)init {
    self=[super init];
    if(self) {
        [self initialise];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self=[super initWithCoder:coder];
    if(self) {
        [self initialise];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self=[super initWithFrame:frameRect];
    if(self) {
        [self initialise];
    }
    return self;
}

- (MIDIDecoder *)decoder {
    return (self.endpoint) ? self.endpoint.decoder : nil;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)action:(id)sender {
}

- (IBAction)doubleAction:(id)sender {
}

- (IBAction)resetButton:(NSButton *)sender {
    [self resetDecoder];
}

- (IBAction)resetFromMenu:(NSMenuItem *)sender {
    [self resetDecoder];
}

- (void)doSomething {
    [self.table reloadData];
    [self.table scrollRowToVisible:[self numberOfRowsInTableView:self.table]-1];
}


- (void)start:(EndpointWrapper *)endpoint {
    if(self.endpoint) [self stopButton:nil];
    
    self.endpoint=endpoint;
    [self resetDecoder];
    __weak Decoder *this=self;
    [self.endpoint setCallback:^{ [this doSomething]; }];
}


- (void)stopButton:(NSButton *)sender {
    [self resetDecoder];
    [self.endpoint setCallback:nil];
    self.endpoint=nil;
    self.filePath=nil;
}

- (void)stopButtonFromMenu:(NSMenuItem *)sender {
    [self stopButton:nil];
}

- (void)resetDecoder {
    [self.decoder reset];
    [self.table reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (self.decoder!=nil ) ? [self.decoder count] : 0;
}

- (NSString *)objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *field=(self.decoder!=nil) ? [self.decoder field:tableColumn.title ofRow:row] : nil;
    return field;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSTextField *result = [tableView makeViewWithIdentifier:@"DecoderReuseTag" owner:self];
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
        CGFloat w=tableView.bounds.size.width/tableView.numberOfColumns;
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,w,30)];
        result.bordered=YES;
        result.bezeled=NO;
        result.identifier = @"DecoderReuseTag";
        result.font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
    }
    NSString *column=tableColumn.title;
    result.alignment=([column isEqualToString:@"Timestamp"] || [column isEqualToString:@"Channel"]) ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    result.stringValue=[self objectValueForTableColumn:tableColumn row:row];
    return result;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn { return NO; }
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableRow:(NSTableColumn *)tableColumn { return YES; }
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row { return NO; }

- (void) noDecoder {
    NSAlert *alert=[[NSAlert alloc] init];
    [alert setAlertStyle: NSWarningAlertStyle];
    [alert setInformativeText:@"No MIDI decoder session is currently running, so none can be saved"];
    [alert setMessageText:@"No session to save"];
    [alert setShowsSuppressionButton:NO];
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSModalResponse returnCode) {
        return;
    }];
}

- (void)save:(id)sender {
    if(!self.decoder) {
        [self noDecoder];
        return;
    }
    if(!self.filePath) [self saveAs:sender];
    NSLog(@"Going for %@",self.filePath);
    
    NSMutableArray *text=[NSMutableArray array];
    [text addObject:[MIDIMessage titlesForCSV]];
    for(MIDIMessage *message in self.decoder.messages) [text addObject:[message asCSV]];
    NSString *output=[text componentsJoinedByString:@"\n"];
    NSError *e;
    [output writeToURL:self.filePath atomically:NO encoding:NSUTF8StringEncoding error:&e];
}



- (void)saveAs:(id)sender {
    if(!self.decoder) {
        [self noDecoder];
        return;
    }
    NSSavePanel *panel=[NSSavePanel savePanel];
    panel.title=@"Save Log As...";
    panel.canCreateDirectories=YES;
    panel.showsHiddenFiles=NO;
    panel.extensionHidden=NO;
    panel.allowedFileTypes=@[@"midi",@"log"];
    if(self.filePath) [panel setDirectoryURL:self.filePath];
    [panel beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSInteger result) {
        if(result==NSFileHandlingPanelOKButton) {
            self.filePath=[panel URL];
            [self save:nil];
        } else {
            NSLog(@"Rejected");
        }
    }];

}

@end
