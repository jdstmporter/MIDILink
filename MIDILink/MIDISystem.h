//
//  MIDISystem.h
//  MIDILink
//
//  Created by Julian Porter on 26/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

typedef enum : NSUInteger {
    MIDIDeviceTypeSource,
    MIDIDeviceTypeDestination,
    MIDIDeviceTypeAll
} MIDIDeviceType;

@interface MIDISystem : NSObject

+ (void) errorWithCode:(OSStatus)code andDescription:(NSString *)description;
+ (NSArray *) enumerate:(MIDIDeviceType)type;


@end
