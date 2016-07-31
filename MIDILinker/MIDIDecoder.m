//
//  MIDIDecoder.m
//  MIDILink
//
//  Created by Julian Porter on 30/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIDecoder.h"





@interface MIDIDecoder ()

@property (strong,atomic) NSLock *lock;

@end

@implementation MIDIDecoder

- (instancetype)init {
    self=[super init];
    if(self) {
        self.messages=[NSMutableArray array];
        self.timeStandard=[[TimeStandard alloc] init];
        self.lock=[[NSLock alloc] init];
    }
    return self;
}

+ (MIDIDecoder *)instance {
    return [[MIDIDecoder alloc] init];
}

- (void)loadPackets:(const MIDIPacketList *)packets {
    NSUInteger nPackets=packets->numPackets;
    if(nPackets>0) {
        const MIDIPacket *packet=&packets->packet[0];
        for(NSUInteger n=0;n<nPackets;n++) {
            MIDIMessage *message=[[MIDIMessage alloc] initFromPacket:packet withTimebase:self.timeStandard];
            [self.messages addObject:message];
            NSLog(@"%@",[message description]);
            
            packet=MIDIPacketNext(packet);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MIDIDatatoDecode" object:nil];
    }
}

- (void)reset {
    [self.lock lock];
    [self.messages removeAllObjects];
    [self.lock unlock];
}

- (NSUInteger)count {
    [self.lock lock];
    NSUInteger n=[self.messages count];
    [self.lock unlock];
    return n;
}

- (NSString *) field:(NSString *)field ofRow:(NSInteger)row {
    NSString *s=nil;
    [self.lock lock];
    @try {
        if(row>=0 && row<[self.messages count]) {
            MIDIMessage *message=[self.messages objectAtIndex:row];
            s=[message valueForKey:field];
        }
    } @catch (NSException *exception) {
        s=nil;
    } @finally {}
    [self.lock unlock];
    return s;
}



@end
