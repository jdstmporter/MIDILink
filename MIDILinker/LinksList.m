//
//  LinksList.m
//  MIDILink
//
//  Created by Julian Porter on 29/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "LinksList.h"
#import "DecoderView.h"

@interface LinksList ()

@property NSInteger selected;
@property (strong) NSMutableArray *links;
@property (readonly) DecoderView *decoderView;
@property (strong) MIDIDecoder *decoder;
@end


@implementation LinksList

- (void) initialise {
    self.links=[NSMutableArray array];
    self.selected=-1;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"MIDIStatusChanged" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"SOMETHING HAPPENNED!!!");
        dispatch_async(dispatch_get_main_queue(),^() {
            [self.linksView reloadData];
        });
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"MIDIDataToDecode" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(dispatch_get_main_queue(),^() {
            [((LinksList *)self.decoderDrawer.contentView).linksView reloadData];
        });
    }];
    self.decoder=[MIDIDecoder instance];
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

- (DecoderView *)decoderView { return (DecoderView *)self.decoderDrawer.contentView; }


- (void)createLinkFrom:(MIDIThing *)source to:(MIDIThing *)destination {
    NSString *name=[[NSUUID UUID] UUIDString];
    LinkWrapper *wrapper=[[LinkWrapper alloc] initWithName:name source:source andDestination:destination];
    [self.links addObject:wrapper];
    [self.linksView reloadData];
    [wrapper link];
}


- (void)action:(NSTableView *)sender {
    NSLog(@"SINGLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
    self.selected=sender.selectedRow;
    [self.linksView reloadData];
    
}

- (void)doubleAction:(NSTableView *)sender {
    if(self.decoderDrawer.state==NSDrawerClosedState) {
        NSLog(@"DOUBLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
        LinkWrapper *link=[self.links objectAtIndex:sender.selectedRow];
        [self.decoderView connect:link];
        [self.decoderDrawer open];
    }
    else if(self.decoderDrawer.state==NSDrawerOpenState) {
        [self.decoderView disconnect];
        [self.decoderDrawer close];
    }
}


- (void) unlink {
    if(self.selected>=0) {
        LinkWrapper *wrapper=[self.links objectAtIndex:self.selected];
        if (self.decoderView.link==wrapper) {
            [self.decoderView disconnect];
            [self.decoderDrawer close];
        }
        [wrapper unlink];
        [self.links removeObjectAtIndex:self.selected];
        self.selected=-1;
        [self.linksView reloadData];
    }
}

- (void)unlinkAll {
    [self.decoderView disconnect];
    [self.decoderDrawer close];

    for (LinkWrapper *wrapper in self.links) [wrapper unlink];
    [self.links removeAllObjects];
    self.selected=-1;
    [self.linksView reloadData];
}





- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (tableView==self.linksView && self.links!=nil) ? [self.links count] : 0;
}

- (id)objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    if(self.links==nil) return nil;
    
    LinkWrapper *link=[self.links objectAtIndex:row];
    if([tableColumn.title isEqualToString:@"Source"]) return link.sourceNameField;
    if([tableColumn.title isEqualToString:@"Destination"]) return link.destinationNameField;
    if([tableColumn.title isEqualToString:@"Activity"]) return link.activityField;
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *reuseTag=[NSString stringWithFormat:@"LinksTable-%@",tableColumn.title];
    BOOL isActivity=[tableColumn.title isEqualToString:@"Activity"];
    
    // Get an existing cell with the MyView identifier if it exists
    NSTextField *result = [tableView makeViewWithIdentifier:reuseTag owner:self];
    
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
        CGFloat w=tableView.bounds.size.width/tableView.numberOfColumns;
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,w,30)];
        result.bordered=YES;
        result.bezeled=NO;
        result.identifier = reuseTag;
    }
    
    if(isActivity) {
        BOOL value = [(NSNumber *)[self objectValueForTableColumn:tableColumn row:row] boolValue];
        if(value) {
            result.backgroundColor=[NSColor whiteColor];
            result.textColor=[NSColor colorWithRed:0 green:0 blue:1 alpha:1];
            result.stringValue=@"◉";
        }
        else {
            result.backgroundColor=[NSColor whiteColor];
            result.stringValue=@"";
        }
        result.alignment=NSTextAlignmentCenter;
    } else {
        NSString *value = (NSString *)[self objectValueForTableColumn:tableColumn row:row];
        result.stringValue=value;
    
        if(row==self.selected) {
            result.backgroundColor=[NSColor blueColor];
            result.textColor=[NSColor whiteColor];
        } else {
            result.backgroundColor=[NSColor whiteColor];
            result.textColor=[NSColor blackColor];
        }
    }
    return result;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn { return NO; }
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableRow:(NSTableColumn *)tableColumn { return YES; }
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row { return NO; }



- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
