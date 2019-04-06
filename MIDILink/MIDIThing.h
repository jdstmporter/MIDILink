//
//  MIDIThing.h
//  MIDILink
//
//  Created by Julian Porter on 26/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>



@interface MIDIThing : NSObject

@property (nonatomic) MIDIObjectRef object;
@property (strong,nonatomic) NSArray *array;
@property (strong,nonatomic) NSDictionary *dictionary;
@property (readonly,nonatomic) MIDIUniqueID uid;
@property (readonly,nonatomic) NSString *name;
@property (readonly,nonatomic) NSString *model;
@property (readonly,nonatomic) NSString *manufacturer;
@property (readonly,nonatomic) NSArray *properties;

@property (readonly,nonatomic) MIDIThing *entity;
@property (readonly,nonatomic) MIDIThing *device;
@property (readonly,nonatomic) MIDIObjectType kind;



- (id)initWithObject:(MIDIObjectRef) object;
//- (id)initWithUID:(MIDIUniqueID) uid;
+ (MIDIThing *) fromObject:(MIDIObjectRef) object;
+ (MIDIThing *) fromUID:(MIDIUniqueID) uid;

- (BOOL) isEndPoint;
- (BOOL) isDevice;
- (BOOL) isEntity;

- (NSString *)stringProperty:(CFStringRef)key;
- (SInt32)integerProperty:(CFStringRef)key;
- (BOOL)booleanProperty:(CFStringRef)key;


+ (void) errorWithCode:(OSStatus)code andDescription:(NSString *)description;

@end

