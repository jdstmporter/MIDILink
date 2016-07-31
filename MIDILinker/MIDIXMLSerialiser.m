//
//  MIDIXMLSerialiser.m
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIXMLSerialiser.h"
#import "MIDIMessage.h"

#define _(x) [NSString stringWithFormat:@"%u",x]

@implementation MIDIXMLSerialiser

- (id) initWithMIDIMessages:(NSArray *)messages {
    self=[super init];
    if(self) {
        self.messages=messages;
        NSXMLElement *root=[[NSXMLElement alloc] initWithName:@"MIDI"];
        self.document=[[NSXMLDocument alloc] initWithRootElement:root];
        self.document.characterEncoding=@"UTF-8";
        self.document.standalone=YES;
    }
    return self;
}

- (void)serialise {
    for(MIDIMessage *message in self.messages) {
        NSString *name;
        NSDictionary *attrs;
        MIDIMessageData packet=message.packet;
        switch(packet.command) {
            case NoteOffEvent:
                name=@"NoteOff";
                attrs=@{@"Channel":_(packet.channel),@"Note":_(packet.arg1),@"Velocity":_(packet.arg2)};
                break;
            case NoteOnEvent:
                name=@"NoteOn";
                attrs=@{@"Channel":_(packet.channel),@"Note":_(packet.arg1),@"Velocity":_(packet.arg2)};
                break;
            case KeyPressure:
                name=@"PolyKeyPressure";
                attrs=@{@"Channel":_(packet.channel),@"Note":_(packet.arg1),@"Pressure":_(packet.arg2)};
                break;
            case ChannelPressure:
                name=@"ChannelKeyPressure";
                attrs=@{@"Channel":_(packet.channel),@"Pressure":_(packet.arg1)};
                break;
            case ControlChange:
                switch(packet.arg1) {
                    case 1:
                        name=@"ModWheel";
                        attrs=@{@"Channel":_(packet.channel),@"Value":_(packet.arg2)};
                    break;
                    case 2:
                        name=@"BreathController";
                        attrs=@{@"Channel":_(packet.channel),@"Value":_(packet.arg2)};
                        break;
                    case 64: {
                        NSString *v=(packet.arg2>=64) ? @"on" : @"off";
                        name=@"Sustain";
                        attrs=@{@"Channel":_(packet.channel),@"Value":v};
                        break;
                    }
                    case 65: {
                        NSString *v=(packet.arg2>=64) ? @"on" : @"off";
                        name=@"Portamento";
                        attrs=@{@"Channel":_(packet.channel),@"Value":v};
                        break;
                    }
                    case 66: {
                        NSString *v=(packet.arg2>=64) ? @"on" : @"off";
                        name=@"Sostenuto";
                        attrs=@{@"Channel":_(packet.channel),@"Value":v};
                        break;
                    }
                    case 67: {
                        NSString *v=(packet.arg2>=64) ? @"on" : @"off";
                        name=@"SoftPedal";
                        attrs=@{@"Channel":_(packet.channel),@"Value":v};
                        break;
                    }
                    case 120:
                        name=@"AllSoundOff";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    case 121:
                        name=@"ResetAllControllers";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    case 122: {
                        NSString *v=(packet.arg2==127) ? @"on" : @"off";
                        name=@"LocalControl";
                        attrs=@{@"Channel":_(packet.channel),@"Value":v};
                        break; }
                    case 123:
                        name=@"AllNotesOff";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    case 124:
                        name=@"OmniOff";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    case 125:
                        name=@"OmniOn";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    case 126:
                        name=@"OMonoMode";
                        attrs=@{@"Channel":_(packet.channel),@"Value":_(packet.arg2)};
                        break;
                    case 127:
                        name=@"PolyMode";
                        attrs=@{@"Channel":_(packet.channel)};
                        break;
                    default:
                        name=@"ControlChange";
                        attrs=@{@"Channel":_(packet.channel),@"Number":_(packet.arg1)};
                        break;
                }
                break;
            case ProgramChange:
                name=@"ProgramChange";
                attrs=@{@"Channel":_(packet.channel),@"Control":_(packet.arg1),@"Value":_(packet.arg2)};
                break;
            case PitchBend:
                name=@"PitchBendChange";
                attrs=@{@"Channel":_(packet.channel),@"Value":_(packet.word)};
                break;
            case SystemMessage:
            default:
                name=@"System";
                attrs=@{@"Message":_(packet.channel-1),@"Byte1":_(packet.arg1),@"Byte2":_(packet.arg2)};
                break;
        }
        
        NSXMLElement *element=[[NSXMLElement alloc] initWithName:name];
        NSMutableDictionary *a=[NSMutableDictionary dictionaryWithDictionary:attrs];
        [a setObject:[NSString stringWithFormat:@"%llu",packet.timestamp] forKey:@"TimeStamp"];
        [element setAttributesWithDictionary:a];
        [self.document.rootElement addChild:element];
    }
}

- (NSData *)serialiseToData {
    [self serialise];
    return self.document.XMLData;
}

- (NSString *)serialiseToString {
    return [[NSString alloc] initWithData:[self serialiseToData] encoding:NSUTF8StringEncoding];
}


@end
