//
//  EndPointList.m
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "EndPointList.h"




@implementation EndPoints

- (void)scan {
    self.source=-1;
    self.destination=-1;
    
    self.sources=[MIDISystem enumerate:MIDIDeviceTypeSource];
    self.destinations=[MIDISystem enumerate:MIDIDeviceTypeDestination];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.sourcesView reloadData];
        [self.destinationsView reloadData];
    });
}

- (nullable EndPointPair *)linkablePair {
    if(self.source>=0 && self.destination>=0) {
        MIDIEndPointDescription *source=[self.sources objectAtIndex:self.source];
        MIDIEndPointDescription *destination=[self.destinations objectAtIndex:self.destination];
        if(source != nil && destination != nil) {
            return [[EndPointPair alloc] initWithSource:[source thing] andDestination:[destination thing]];
        }
    }
    return nil;
}

- (void)action:(nullable NSTableView *)sender {
    NSLog(@"SINGLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
    if(sender==self.sourcesView) {
        NSInteger sel=sender.selectedRow;
        self.source=(self.source==sel) ? -1 : sel;
    }
    if(sender==self.destinationsView) {
        NSInteger sel=sender.selectedRow;
        self.destination=(self.destination==sel) ? -1 : sel;
    }
    [sender reloadData];
}

- (void)doubleAction:(nullable NSTableView *)sender {
    NSLog(@"DOUBLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (NSInteger)numberOfRowsInTableView:(nonnull NSTableView *)tableView {
    if(tableView==self.sourcesView) {
        return (self.sources==nil) ? 0 : [self.sources count];
    } else if(tableView==self.destinationsView) {
        return (self.destinations==nil) ? 0 : [self.destinations count];
    } else return 0;
}

- (nullable id)tableView:(nonnull NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSArray *data=(tableView==self.sourcesView) ? self.sources : self.destinations;
    if(data!=nil) {
        MIDIEndPointDescription *endpoint=[data objectAtIndex:row];
        NSString *key=tableColumn.title;
        return [endpoint valueForKey:key];
    }
    return nil;
}

- (void)tableView:(nonnull NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
}


- (nullable NSView *)tableView:(nonnull NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    // Get an existing cell with the MyView identifier if it exists
    NSTextField *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
        
        // Create the new NSTextField with a frame of the {0,0} with the width of the table.
        // Note that the height of the frame is not really relevant, because the row height will modify the height.
        CGFloat w=tableView.bounds.size.width/tableView.numberOfColumns;
        result = [[NSTextField alloc] initWithFrame:NSMakeRect(0,0,w,30)];
        result.bordered=YES;
        result.bezeled=NO;
        if([tableColumn.title isEqualToString:@"UID"]) {
            result.font=[NSFont fontWithName:@"CourierNewPSMT" size:12.0];
            result.alignment=NSTextAlignmentCenter;
        }

        
        // The identifier of the NSTextField instance is set to MyView.
        // This allows the cell to be reused.
        result.identifier = @"MyView";
    }
    
    // Set the stringValue of the cell's text field to the nameArray value at row
    result.stringValue = (NSString *)[self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    NSInteger sel=(tableView==self.sourcesView) ? self.source : self.destination;
    
    if(row==sel) {
        result.backgroundColor=[NSColor blueColor];
        result.textColor=[NSColor whiteColor];
    } else {
        result.backgroundColor=[NSColor whiteColor];
        result.textColor=[NSColor blackColor];
    }
    
    // Return the result
    return result;
}

-(CGFloat)tableView:(nonnull NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column {
    return tableView.bounds.size.width/tableView.numberOfColumns;
}

- (BOOL)tableView:(nonnull NSTableView *)tableView shouldSelectTableColumn:(nullable NSTableColumn *)tableColumn { return NO; }
- (BOOL)tableView:(nonnull NSTableView *)tableView shouldSelectTableRow:(nullable NSTableColumn *)tableColumn { return YES; }
- (BOOL)tableView:(nonnull NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row { return NO; }

@end
