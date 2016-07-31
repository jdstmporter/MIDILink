//
//  MIDICSVSerialiser.m
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDICSVSerialiser.h"
#import "MIDIMessage.h"

@implementation MIDICSVSerialiser

- (id)initWithMIDIMessages:(NSArray *)messages {
    self=[super init];
    if(self) {
        self.messages=messages;
        self.rows=[NSMutableArray array];
    }
    return self;
}

- (void)serialise {
    [self.rows addObject:@"Timestamp,Command,Channel,Arguments,Byte1,Byte2,Byte3"];
    for(MIDIMessage *message in self.messages) {
        NSString *row=[NSString stringWithFormat:@"%@,%@,%@,%@,%u,%u,%u",message.Timestamp,message.Command,message.Channel,message.Arguments,
                       message.packet.arg0,message.packet.arg1,message.packet.arg2];
        [self.rows addObject:row];
    }
}

- (NSString *)serialiseToString {
    return [self.rows componentsJoinedByString:@"\n"];
}

- (NSData *)serialiseToData {
    return [[self serialiseToString] dataUsingEncoding:NSUTF8StringEncoding];
}


@end


