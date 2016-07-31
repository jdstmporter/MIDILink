//
//  main.m
//  MIDILink
//
//  Created by Julian Porter on 26/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDISystem.h"
#import "MIDIThing.h"
#import "Endpoint.h"
#import "MIDILink.h"

void show(NSString *kind,MIDIThing *e,NSString *offset) {
    MIDIEndPointDescription *d=[[MIDIEndPointDescription alloc] initWithThing:e];
    NSLog(@"%@%@",offset,[d description]);
    //   NSLog(@"%@%@ has %lu properties",offset,kind,[e.properties count]);
    //for(NSString *s in e.properties) NSLog(@"%@    - %@",offset,s);
}


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSArray *array1=[MIDISystem enumerate:MIDIDeviceTypeSource];
        NSLog(@"Got %lu sources",[array1 count]);
        for(MIDIThing *e in array1) {
            show(@"Endpoint",e,@"");
//            MIDIThing *en=e.entity;
//            if(en!=nil) {
//                show(@"Entity",en,@"  ");
//                MIDIThing *d=en.device;
//                if(d!=nil) {
//                    show(@"Device",d,@"    ");
//                }
//            }
        }
        MIDIThing *source=[array1 objectAtIndex:1];
        
        NSArray *array2=[MIDISystem enumerate:MIDIDeviceTypeDestination];
        NSLog(@"Got %li destinations",[array2 count]);
        for(MIDIThing *e in array2) {
            show(@"Endpoint",e,@"");
//            MIDIThing *en=e.entity;
//            if(en!=nil) {
//                show(@"Entity",en,@"  ");
//                MIDIThing *d=en.device;
//                if(d!=nil) {
//                    show(@"Device",d,@"    ");
//                }
//            }
        }
        MIDIThing *destination=[array2 objectAtIndex:2];
        
        NSLog(@"[%ul] -> [%ul]",source.uid,destination.uid);
        MIDIClient *link=[[MIDIClient alloc] initWithName:@"Link"];
        [link connectSourceTo:source];
        [link connectDestinationTo:destination];
        [link link];
        NSLog(@"Linked");
        
        char str[80];
        scanf("%s",str);
        
        
        [link unlink];
    }
    return 0;
}
