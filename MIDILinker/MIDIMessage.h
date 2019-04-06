//
//  MIDIMessage.h
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "TimeBase.h"


/*
typedef enum : Byte {
    NoteOffEvent    = 0x80,
    NoteOnEvent     = 0x90,
    KeyPressure     = 0xa0,
    ControlChange   = 0xb0,
    ProgramChange   = 0xc0,
    ChannelPressure = 0xd0,
    PitchBend       = 0xe0,
    SystemMessage   = 0xf0,
    UNKNOWN         = 0
} MIDICommandTypes;
*/

/*
typedef struct {
    MIDITimeStamp timestamp;
    MIDICommandTypes command;
    UInt8 channel;
    Byte arg0;
    Byte arg1;
    Byte arg2;
    UInt16 word;
} MIDIMessageData;

MIDIMessageData MIDIMakeMessageData(const MIDIPacket *packet);
NSString * _(Byte b);



@interface MIDIMessage : NSObject

@property (strong,atomic) NSString *Timestamp;
@property (strong,atomic) NSString *Command;
@property (strong,atomic) NSString *Arguments;
@property (strong,atomic) NSString *Channel;
@property (readonly) MIDIMessageData packet;

- (NSString *) asCSV;
+ (NSString *) titlesForCSV;

- (id) initFromPacket:(const MIDIPacket *)data withTimebase:(TimeStandard *)timeStandard;
+ (NSString *) NameForCommand:(Byte)command;
+ (MIDIMessage *) packet:(const MIDIPacket *)packet withTimebase:(TimeStandard *)timeStandard;




@end
*/


@interface MIDIBuilder : NSObject

+ (MIDICommandTypes *) commandTypes;
+ (NSString * __strong *)commandNames;
+ (NSUInteger)nCommandTypes;
+ (NSString *) commandNameForIndex:(NSInteger) index;
+ (NSInteger) indexForCommandType:(MIDICommandTypes)type;

+ (Byte) controllerCodeAtIndex:(NSInteger)index;
+ (NSString *)nameAtIndex:(NSInteger)index;
+ (NSInteger) nControlChangeCodes;
+ (BOOL) isControlCode:(Byte) b;
+ (NSArray *) dataBytesForType:(MIDICommandTypes)type;

@property (atomic) Byte status;
@property (atomic) Byte data1;
@property (atomic) Byte data2;

@property (nonatomic) UInt8 channel;
@property (nonatomic) MIDICommandTypes type;

- (instancetype)init;
- (MIDIPacket) getPacket;
- (MIDIPacketList) getPacketList;




@end
