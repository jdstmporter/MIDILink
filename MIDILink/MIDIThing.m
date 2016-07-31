//
//  MIDIThing.m
//  MIDILink
//
//  Created by Julian Porter on 26/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIThing.h"

@interface MIDIThing ()

- (void) initialise:(MIDIObjectRef)object;

@end


@implementation MIDIThing
@synthesize kind=_kind;
@synthesize device=_device;
@synthesize entity=_entity;

+ (void) errorWithCode:(OSStatus)code andDescription:(NSString *)description {
    [[NSException exceptionWithName:@"MIDI Error"
                             reason:[NSString stringWithFormat:@"Error %d - %@",code,description]
                           userInfo:nil ] raise];
}

- (id)initWithUID:(MIDIUniqueID)uid {
    self=[super init];
    if(self) {
        MIDIObjectRef object;
        MIDIObjectType kind;
        OSStatus error=MIDIObjectFindByUniqueID(self.uid, &object, &kind);
        if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot get object type"];
        [self initialise: object];
    }
    return self;
}

- (id)initWithObject:(MIDIObjectRef)object {
    self=[super init];
    if(self) {
        [self initialise: object];
    }
    return self;
}

- (void) dealloc {
    switch(_kind) {
        case kMIDIObjectType_Source:
        case kMIDIObjectType_Destination:
            MIDIEndpointDispose(self.object);
            break;
        case kMIDIObjectType_Device:
            MIDIDeviceDispose(self.object);
            break;
        default:
            break;
    }
}

- (void) initialise:(MIDIObjectRef)object {
    self.object=object;
        CFPropertyListRef props;
        OSStatus error=MIDIObjectGetProperties(self.object, &props, NO);
    if(error!=noErr) {
        NSLog(@"Erroneous object is %d",object);
        [MIDIThing errorWithCode:error andDescription:@"Cannot get object properties"];
    }
        
        CFTypeID type=CFGetTypeID(props);
        if(type==CFDictionaryGetTypeID()) {
            CFDictionaryRef d=props;
            self.dictionary=(NSDictionary *)CFBridgingRelease(d);
            self.array=[NSArray array];
        } else if(type==CFArrayGetTypeID()) {
            CFArrayRef a=props;
            self.dictionary=[NSDictionary dictionary];
            self.array=(NSArray *)CFBridgingRelease(a);
        } else [MIDIThing errorWithCode:error andDescription:@"Bad object properties"];
        
        MIDIObjectRef tmp;
        MIDIObjectType kind;
        error=MIDIObjectFindByUniqueID(self.uid, &tmp, &kind);
        if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot get object type"];
        _kind=kind;
        
        if(kind==kMIDIObjectType_Source || kind==kMIDIObjectType_Destination) {
            MIDIEntityRef entity;
            
            OSStatus error=MIDIEndpointGetEntity((MIDIEndpointRef)self.object, &entity);
            if(error==kMIDIObjectNotFound) {
                _entity=nil;
                _device=nil;
            }
            else if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot get endpoint entity"];
            else  {
                _entity=[MIDIThing fromObject:entity];
                _device=_entity.device;
            }
        }
        else if(kind==kMIDIObjectType_Entity) {
            _entity=self;
            
            MIDIDeviceRef device;
            OSStatus error=MIDIEntityGetDevice((MIDIEntityRef)self.object, &device);
            if(error==kMIDIObjectNotFound) _device=nil;
            else if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot get entity device"];
            else _device=[MIDIThing fromObject:device];
        }
        else if(kind==kMIDIObjectType_Device) {
            _entity=nil;
            _device=self;
        }
        else {
            _entity=nil;
            _device=nil;
        }
}


+ (MIDIThing *)fromObject:(MIDIObjectRef)object {
    return [[MIDIThing alloc] initWithObject:object];
}

+ (MIDIThing *)fromUID:(MIDIUniqueID)uid {
    return [[MIDIThing alloc] initWithUID:uid];
}

- (BOOL)isEndPoint {
    return (_kind==kMIDIObjectType_Source || _kind==kMIDIObjectType_Destination);
}

- (BOOL)isEntity {
    return (_kind==kMIDIObjectType_Entity);
}

- (BOOL)isDevice {
    return (_kind==kMIDIObjectType_Device);
}




- (NSArray *)properties {
    return [self.dictionary allKeys];
}

- (MIDIUniqueID)uid {
    return [self integerProperty:kMIDIPropertyUniqueID];
}

- (NSString *)name {
    return [self stringProperty:kMIDIPropertyName];
}

- (NSString *)model {
    return [self stringProperty:kMIDIPropertyModel];
}

- (NSString *)manufacturer {
    return [self stringProperty:kMIDIPropertyManufacturer];
}

- (NSString *)stringProperty:(const CFStringRef)key {
    return [self.dictionary objectForKey:(__bridge id _Nonnull)(key)];
}

- (SInt32)integerProperty:(const CFStringRef)key {
    NSNumber *value=[self.dictionary objectForKey:(__bridge id _Nonnull)(key)];
    if (value==nil) return -1;
    return [value intValue];
}

- (BOOL)booleanProperty:(CFStringRef)key {
    SInt32 value=[self integerProperty:key];
    return value==1;
}

@end

