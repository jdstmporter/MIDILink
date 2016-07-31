//
//  MIDISystem.m
//  MIDILink
//
//  Created by Julian Porter on 26/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDISystem.h"
#import "MIDIThing.h"
#import "Endpoint.h"


@implementation MIDISystem

+ (void) errorWithCode:(OSStatus)code andDescription:(NSString *)description {
    [[NSException exceptionWithName:@"MIDI Error"
                             reason:[NSString stringWithFormat:@"Error %d - %@",code,description]
                           userInfo:nil ] raise];
}




+ (NSArray *)enumerate:(MIDIDeviceType)type {
    ItemCount n;
    NSMutableArray *items=[NSMutableArray array];
    NSLog(@"Enumerating . . .");
    switch (type) {
        case MIDIDeviceTypeSource: {
            n=MIDIGetNumberOfSources();
            for(ItemCount i=0;i<n;i++) {
                MIDIEndpointRef device=MIDIGetSource(i);
                MIDIThing *thing=[MIDIThing fromObject:device];
                [items addObject:[[MIDIEndPointDescription alloc] initWithThing:thing]];
                
            }
            break; }
        case MIDIDeviceTypeDestination: {
            n=MIDIGetNumberOfDestinations();
            for(ItemCount i=0;i<n;i++) {
                MIDIEndpointRef device=MIDIGetDestination(i);
                MIDIThing *thing=[MIDIThing fromObject:device];
                [items addObject:[[MIDIEndPointDescription alloc] initWithThing:thing]];

            }
            break; }
        case MIDIDeviceTypeAll: {
            n=MIDIGetNumberOfSources();
            NSLog(@"NSources = %ld",n);
            for(ItemCount i=0;i<n;i++) {
                MIDIEndpointRef device=MIDIGetSource(i);
                MIDIThing *thing=[MIDIThing fromObject:device];
                [items addObject:[[MIDIEndPointDescription alloc] initWithThing:thing]];
                
            }
            n=MIDIGetNumberOfDestinations();
            NSLog(@"NDestinations = %ld",n);
            for(ItemCount i=0;i<n;i++) {
                MIDIEndpointRef device=MIDIGetDestination(i);
                MIDIThing *thing=[MIDIThing fromObject:device];
                [items addObject:[[MIDIEndPointDescription alloc] initWithThing:thing]];
            }
            break; }
    }
    NSLog(@"Item has length %ld",[items count]);
    for(MIDIEndPointDescription *d in items) NSLog(@"%@",d);
    return items;
    
}

@end
