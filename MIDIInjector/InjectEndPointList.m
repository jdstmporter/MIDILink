//
//  EndPointList.m
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "InjectEndPointList.h"



@implementation InjectEndPointView

- (void)scan {
    self.endpoint=-1;
    
    self.endpoints=[MIDISystem enumerate:MIDIDeviceTypeDestination];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self tableView:self.view sortDescriptorsDidChange:[self.view sortDescriptors]];
    });
}



- (void)action:(NSTableView *)sender {
    NSLog(@"SINGLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
    if(sender==self.view) {
        NSInteger sel=sender.selectedRow;
        self.endpoint=(self.endpoint==sel) ? -1 : sel;
    }
    [sender reloadData];
}

- (void)doubleAction:(NSTableView *)sender {
    NSLog(@"DOUBLE Table : ROW %ld COLUMN %ld",sender.selectedRow,sender.selectedColumn);
}

- (MIDIEndPointDescription *)selected {
    if(self.endpoint<0 || self.endpoint>=[self.endpoints count]) return nil;
    MIDIEndPointDescription *d=[self.endpoints objectAtIndex:self.endpoint];
    NSLog(@"Endpoint %@ UID %@",[d description],d.UID);
    //NSString *name=[[NSUUID UUID] UUIDString];
    //NSLog(@"Creating wrapper with name %@ and thing %@",name,[d.thing description]);
    //return [[EndpointWrapper alloc] initWithName:name andEndpoint:d.thing];
    return d;
    
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(nonnull NSArray<NSSortDescriptor *> *)oldDescriptors {
    self.endpoints=[self.endpoints sortedArrayUsingDescriptors:[tableView sortDescriptors]];
    [tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(tableView==self.view) {
        return (self.endpoints==nil) ? 0 : [self.endpoints count];
    }   else return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSArray *data=(tableView==self.view) ? self.endpoints : nil;
    if(data!=nil) {
        MIDIEndPointDescription *endpoint=[data objectAtIndex:row];
        NSString *key=tableColumn.title;
        NSLog(@"Key is %@, result is %@",key,[endpoint valueForKey:key]);
        return [endpoint valueForKey:key];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
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
    NSString *value=(NSString *)[self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    result.stringValue =(value==nil) ? @"-" : value;
    NSInteger sel=(tableView==self.view) ? self.endpoint : -1;
    
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

-(CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column {
    return tableView.bounds.size.width/tableView.numberOfColumns;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableColumn:(NSTableColumn *)tableColumn { return NO; }
- (BOOL)tableView:(NSTableView *)tableView shouldSelectTableRow:(NSTableColumn *)tableColumn { return YES; }
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row { return NO; }

@end
