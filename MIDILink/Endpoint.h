//
//  Endpoint.h
//  MIDILink
//
//  Created by Julian Porter on 27/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MIDIThing.h"
//#import "MIDISystem.h"

typedef enum : char {
    MIDIEndPointObject='P',
    MIDIEntityObject='E',
    MIDIDeviceObject='D',
    MIDIUnknownObject='O'
} MIDIThingKind;

@interface MIDIEndPointDescription : NSObject

@property (atomic) MIDIUniqueID uid;
@property (copy,nonatomic) NSString * _Nonnull UID;
@property (copy,nonatomic) NSString * _Nullable Name;
@property (copy,nonatomic) NSString * _Nullable Model;
@property (copy,nonatomic) NSString * _Nullable Manufacturer;
@property (nonatomic,readonly) NSString * _Nullable Kind;
@property (nonatomic) BOOL embedded;
@property (nonatomic)BOOL transmitsNotes;
@property (nonatomic)BOOL receivesNotes;
@property (atomic) MIDIThingKind type;
@property (readonly,nonatomic) NSString * _Nullable typeName;
@property (strong,nonatomic) MIDIThing * _Nullable thing;
@property (readonly,nonatomic) MIDIObjectRef object;

- (id _Nonnull) initWithThing:(MIDIThing * _Nullable)thing;

- (NSString * _Nullable)stringProperty:(CFStringRef _Nullable)key;

@end

@interface EndPointPair : NSObject

@property (strong,nonatomic) MIDIThing * _Nullable source;
@property (strong,nonatomic) MIDIThing * _Nullable destination;

- (id _Nonnull) initWithSource:(MIDIThing * _Nullable)source andDestination:(MIDIThing * _Nullable)destination;

@end

