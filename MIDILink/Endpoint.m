//
//  Endpoint.m
//  MIDILink
//
//  Created by Julian Porter on 27/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "Endpoint.h"

@implementation MIDIEndPointDescription


- (id)initWithThing:(MIDIThing *)thing {
    self=[super init];
    if(self) {
        self.thing=thing;
        self.uid=thing.uid;
        
        
        if ([thing isEndPoint]) self.type=MIDIEndPointObject;
        else if ([thing isEntity]) self.type=MIDIEntityObject;
        else if ([thing isDevice]) self.type=MIDIDeviceObject;
        else self.type=MIDIUnknownObject;
        
        self.UID=          [NSString stringWithFormat:@"%u",self.uid];
        self.Name=         [self stringProperty:kMIDIPropertyName];
        self.Model=        [self stringProperty:kMIDIPropertyModel];
        self.Manufacturer= [self stringProperty:kMIDIPropertyManufacturer];
    }
    
    return self;
}

- (MIDIObjectRef)object {
    return self.thing.object;
}

- (NSString *)stringProperty:(CFStringRef)key {
    NSString *s=[self.thing stringProperty:key];
    if(s==nil && self.thing.entity!=nil) s=[self.thing.entity stringProperty:key];
    if(s==nil && self.thing.device!=nil) s=[self.thing.device stringProperty:key];
    return s;
}

- (NSString *)typeName {
    switch (self.type) {
        case MIDIEndPointObject:
            return @"Endpoint";
            break;
        case MIDIEntityObject:
            return @"Entity";
            break;
        case MIDIDeviceObject:
            return @"Device";
            break;
        default:
            return @"Unknown";
            break;
    }
}

- (NSString *)Kind {
    switch(self.thing.kind) {
        case kMIDIObjectType_Source:
        case kMIDIObjectType_ExternalSource:
            return @"source";
            break;
        case kMIDIObjectType_Destination:
        case kMIDIObjectType_ExternalDestination:
            return @"destination";
            break;
        default:
            return @"-";
            break;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%@] %@ %@ %@",self.UID,self.Name,self.Model,self.Manufacturer];
}

@end

@implementation EndPointPair

- (nonnull id)initWithSource:(nullable MIDIThing *)source andDestination:(nullable MIDIThing *)destination {
    self=[super init];
    if(self) {
        self.source=source;
        self.destination=destination;
    }
    return self;
}

@end