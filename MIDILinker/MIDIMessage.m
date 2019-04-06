//
//  MIDIMessage.m
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIMessage.h"


static NSDictionary *commandNames;


@interface MIDIMessage ()

@property (strong,nonatomic) NSArray *fields;
@property (nonatomic) MIDIMessageData packet;


@end
/*
MIDIMessageData MIDIMakeMessageData(const MIDIPacket *packet) {
    Byte *data=(Byte *)packet->data;
    MIDICommandTypes command=data[0]&0xf0;
    UInt8 channel=1+(data[0]&0x0f);
    Byte arg1=data[1];
    Byte arg2=data[2];
    UInt16 word=(((UInt16)arg2)<<8) + arg1;
    return (MIDIMessageData) {packet->timeStamp,command,channel,data[0],arg1,arg2,word};
}

NSString * _(Byte b) {
    return [NSString stringWithFormat:@"%02x",b];
}
*/

@implementation MIDIMessage
/*
+ (NSString *)NameForCommand:(Byte)command {
    if (commandNames==nil) {
        commandNames=@{@(NoteOffEvent)    : @"Note Off",
                       @(NoteOnEvent)     : @"Note On",
                       @(KeyPressure)     : @"Key Pressure",
                       @(ControlChange)   : @"Control Change",
                       @(ProgramChange)   : @"Program Change",
                       @(ChannelPressure) : @"Channel Pressure",
                       @(PitchBend)       : @"Pitch Bend",
                       @(SystemMessage)   : @"System",
                       @(UNKNOWN)         : @""};
    }
    return [commandNames objectForKey:@(command)];
}
 */

- (id)initFromPacket:(const MIDIPacket *)packet withTimebase:(TimeStandard *)timeStandard {
    
    self=[super init];
    if(self) {
        
        UInt16 length=packet->length;
        self.packet=MIDIMakeMessageData(packet);
        
        Byte command=UNKNOWN;
        NSString *args=@"";
        if(length>0) {
            command=self.packet.command;
            switch(command) {
                case NoteOffEvent:
                case NoteOnEvent:
                    args=[NSString stringWithFormat: @"Note=%d, Velocity=%d",self.packet.arg1,self.packet.arg2];
                    break;
                case KeyPressure:
                    args=[NSString stringWithFormat: @"Note=%d, Pressure=%d",self.packet.arg1,self.packet.arg2];
                    break;
                case ChannelPressure:
                    args=[NSString stringWithFormat: @"Pressure=%d",self.packet.arg1];
                    break;
                case ControlChange: {
                    NSString *argRoot=[NSString stringWithFormat: @"Controller=%d, Value=%d",self.packet.arg1,self.packet.arg2];
                    switch(self.packet.arg1) {
                            
                        case 1:
                            args=[NSString stringWithFormat:@"Modulation wheel=%d",self.packet.arg2];
                            break;
                        case 2:
                            args=[NSString stringWithFormat:@"Breath controller=%d",self.packet.arg2];
                            break;
                        case 64: {
                            NSString *v=(self.packet.arg2>=64) ? @"ON" : @"OFF";
                            args=[NSString stringWithFormat: @"Sustain=%@",v];
                            break;
                        }
                        case 65: {
                            NSString *v=(self.packet.arg2>=64) ? @"ON" : @"OFF";
                            args=[NSString stringWithFormat: @"Portamento=%@",v];
                            break;
                        }
                        case 66: {
                            NSString *v=(self.packet.arg2>=64) ? @"ON" : @"OFF";
                            args=[NSString stringWithFormat: @"Sostenuto=%@",v];
                            break;
                        }
                        case 67: {
                            NSString *v=(self.packet.arg2>=64) ? @"ON" : @"OFF";
                            args=[NSString stringWithFormat: @"Soft pedal=%@",v];
                            break;
                        }
                        case 120:
                            args=@"All sound=off";
                            break;
                        case 121:
                            args=[NSString stringWithFormat: @"Reset all controllers=%ud",self.packet.arg2];
                            break;
                        case 122: {
                            NSString *v=(self.packet.arg2==127) ? @"ON" : @"OFF";
                            args=[NSString stringWithFormat: @"Local control=%@",v];
                            break; }
                        case 123:
                            args=@"All notes=off";
                            break;
                        case 124:
                            args=@"Omni mode=off";
                            break;
                        case 125:
                            args=@"Omni mode=on";
                            break;
                        case 126:
                            args=[NSString stringWithFormat:@"Mono mode=%ud",self.packet.arg2];
                            break;
                        case 127:
                            args=@"Poly mode=on";
                            break;
                        default:
                            args=nil;
                            break;
                    }
                    args=(args) ? [argRoot stringByAppendingFormat:@" (%@)",args] : argRoot;
                    break;
                }
                case ProgramChange:
                    args=[NSString stringWithFormat: @"Program=%d",self.packet.arg1];
                    break;
                case PitchBend:
                    args=[NSString stringWithFormat: @"Bend=%d",self.packet.word];
                    break;
                case SystemMessage:
                default:
                    args=@"";
                    break;
            }
            
        }
        self.fields=@[@"Timestamp",@"Command",@"Channel",@"Arguments"];
        MIDITimeStamp timestamp=self.packet.timestamp;
        self.Timestamp=[timeStandard convert:timestamp];
        self.Command=[MIDIMessage NameForCommand:command];
        self.Arguments=args;
        self.Channel=(command==SystemMessage) ? @"" : [NSString stringWithFormat:@"%d",self.packet.channel];
        
        
        
    }
    return self;
}



- (NSString *)description {
    NSMutableString *s=[NSMutableString string];
    [self.fields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *v=[self valueForKey:obj];
        [s appendFormat:@" %@ : %@ ",obj,v];
    }];
    return s;
}

+ (MIDIMessage *)packet:(const MIDIPacket *)packet withTimebase:(TimeStandard *)timeStandard{
    return [[MIDIMessage alloc] initFromPacket:packet withTimebase:(TimeStandard *)timeStandard];
}

- (NSString *)asCSV {
    NSArray *f=@[self.Timestamp,_(self.packet.channel),_(self.packet.command),_(self.packet.arg1),_(self.packet.arg2),
                        self.Channel,self.Command,self.Arguments];
    NSMutableArray *g=[NSMutableArray array];
    for(NSString *s in f) [g addObject:[NSString stringWithFormat:@"\"%@\"",s]];
    return [g componentsJoinedByString:@","];
}

+ (NSString *)titlesForCSV {
    return @"timestamp, channel, command, byte1, byte 2, \"decoded channel\",\"decoded command\",\":decoded arguments\"";
}



@end

static MIDICommandTypes MIDICommands[8]={(NoteOffEvent),(NoteOnEvent),(KeyPressure),(ControlChange),(ProgramChange),(ChannelPressure),(PitchBend),(SystemMessage)};
static NSString * MIDICommandNames[8]={ @"Note Off", @"Note On", @"Key Pressure", @"Control Change", @"Program Change", @"Channel Pressure", @"Pitch Bend", @"System" };
static NSDictionary *controllers=nil;
static NSArray *controllerKeys=nil;

@implementation MIDIBuilder

+ (MIDICommandTypes *)commandTypes {
    return MIDICommands;
}

+ (NSInteger) indexForCommandType:(MIDICommandTypes)type {
    for(NSInteger i=0;i<8;i++) if(type==MIDICommands[i]) return i;
    return -1;
}

+ (NSUInteger)nCommandTypes {
    return 8;
}

+ (NSString * __strong *)commandNames {
    return MIDICommandNames;
}

+ (NSString *) commandNameForIndex:(NSInteger) index {
    return MIDICommandNames[index];
}

+ (NSArray *) dataBytesForType:(MIDICommandTypes)type {
    switch(type) {
        case NoteOffEvent:
        case NoteOnEvent:
            return @[@"Note",@"Velocity"];
        case KeyPressure:
            return @[@"Note",@"Pressure"];
        case ControlChange:
            return @[@"Controller",@"Value"];
        case ProgramChange:
            return @[@"Program"];
        case ChannelPressure:
            return @[@"Pressure"];
        case PitchBend:
            return @[@"Lo",@"Hi"];
        case SystemMessage:
            return @[];
        default:
            return nil;
    }
}

+ (NSDictionary *)controlChangeCodes {
    if(controllers==nil) {
        controllers=@{ @(1) : @"Modulation Wheel", @(2) : @"Breath controller", @(64) : @"Sustain", @(65) : @"Portamento", @(66) : @"Sostenuto", @(67) : @"Soft Pedal", @(120): @"All sound off", @(121): @"Reset all controllers", @(122): @"Local", @(123): @"All notes off", @(124): @"Omni mode off", @(125): @"Omni mode on", @(126) : @"Mono mode", @(127) : @"Poly mode", @(0) : @"Other" };
        controllerKeys=[[controllers allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [(NSNumber *)obj1 compare:obj2];
        }];
    }
   return controllers;
}

+ (Byte) controllerCodeAtIndex:(NSInteger)index {
    if(controllers==nil) [MIDIBuilder controlChangeCodes];
    return [(NSNumber *)[controllerKeys objectAtIndex:index] integerValue];
}

+ (NSString *)nameAtIndex:(NSInteger)index {
    if(controllers==nil) [MIDIBuilder controlChangeCodes];
    NSNumber *n=[NSNumber numberWithInteger:[MIDIBuilder controllerCodeAtIndex:index]];
    return [controllers objectForKey:n];
}

+ (NSInteger) nControlChangeCodes {
    if(controllers==nil) [MIDIBuilder controlChangeCodes];
    return [controllerKeys count];
}

+ (BOOL) isControlCode:(Byte) b {
    if(controllers==nil) [MIDIBuilder controlChangeCodes];
    return [controllerKeys containsObject:[NSNumber numberWithInteger:b]];
}






- (instancetype)init {
    self=[super init];
    if(self) {
        self.status=0;
        self.data1=0;
        self.data2=0;
    }
    return self;
}

- (NSInteger) length {
    return 1+[[MIDIBuilder dataBytesForType:self.status] count];
}

- (UInt8)channel {
    return self.status&0x0f;
}

- (void)setChannel:(UInt8)channel {
    self.status=self.type|(channel&0x0f);
}

- (MIDICommandTypes)type {
    return self.status&0xf0;
}

- (void)setType:(MIDICommandTypes)type {
    self.status=type | self.channel;
}

- (MIDIPacket)getPacket {
    MIDIPacket p={0};
    p.timeStamp=0;
    p.length=[self length];
    p.data[0]=self.status;
    p.data[1]=self.data1;
    p.data[2]=self.data2;
    return p;
}

- (MIDIPacketList)getPacketList {
    MIDIPacketList l={0};
    l.numPackets=1;
    l.packet[0]=[self getPacket];
    return l;
}

@end

