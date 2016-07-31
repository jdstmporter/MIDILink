//
//  DecoderView.m
//  MIDILink
//
//  Created by Julian Porter on 01/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "DecoderView.h"



@interface DecoderView ()

@property (strong,nonatomic)  LinkWrapper * _Nullable link;
@property (readonly)  MIDIDecoder * _Nullable decoder;
@end


@implementation DecoderView

- (void) initialise {
    self.link=nil;
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
    return (self.link) ? self.link.decoder : nil;
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


- (void)connect:(LinkWrapper *)link {
    self.link=link;
    [self resetDecoder];
    [link setCallback:^{
        [self.table reloadData];
        [self.table scrollRowToVisible:[self numberOfRowsInTableView:self.table]-1];
    }];
}

- (void)disconnect {
    [self resetDecoder];
    [self.link setCallback:nil];
    self.link=nil;
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


@end
