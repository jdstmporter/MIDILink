//
//  MIDIJSONSerialiser.m
//  MIDILink
//
//  Created by Julian Porter on 03/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIJSONSerialiser.h"
#import "MIDIMEssage.h"

@implementation MIDIJSONSerialiser

- (id)initWithMIDIMessages:(NSArray *)messages {
    self=[super init];
    if(self) {
        self.messages=messages;
        self.objects=[NSMutableArray array];
    }
    return self;
}

- (void)serialise {
    for(MIDIMessage *message in self.messages) {
        NSMutableDictionary *item=[NSMutableDictionary dictionary];
        [item setObject:message.Command forKey:@"MessageType"];
        if([message.Channel length]>0) [item setObject:message.Channel forKey:@"Channel"];
        [item setObject:message.Timestamp forKey:@"Timestamp"];
        [item setObject:[NSString stringWithFormat:@"%llu",message.packet.timestamp] forKey:@"RawTimestamp"];
        NSArray *bits=[message.Arguments componentsSeparatedByString:@","];
        for(NSString *bit in bits) {
            if([bit containsString:@"="]) {
                NSArray *parts=[bit componentsSeparatedByString:@"="];
                if([parts count]>=2) [item setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
            }
        }
        [self.objects addObject:item];
    }
}

- (NSData *)serialiseToData {
    [self serialise];
    NSError *error;
    return [NSJSONSerialization dataWithJSONObject:self.objects options:NSJSONWritingPrettyPrinted error:&error];
}

- (NSString *)serialiseToString {
    return [[NSString alloc] initWithData:[self serialiseToData] encoding:NSUTF8StringEncoding];
}

@end
