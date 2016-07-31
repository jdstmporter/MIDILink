//
//  LinkWrapper.m
//  MIDILink
//
//  Created by Julian Porter on 30/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "LinkWrapper.h"
#import <libkern/OSAtomic.h>
#import "MIDIDecoder.h"



@interface LinkWrapper ()

@property (nonatomic) int32_t *counter;
@property (nonatomic) BOOL active;
@property (strong,nonatomic) MIDIDecoder *decoder;
@property (nonatomic) DecoderUpdate callback;

- (void) callbackWithPackets:(const MIDIPacketList *)packets andStatus:(OSStatus)status;

@end

@implementation LinkWrapper

- (instancetype)initWithName:(NSString *)name source:(MIDIThing *)source andDestination:(MIDIThing *)destination {
    self=[super init];
    if(self) {
        self.client=[[MIDIClient alloc] initWithName:name];
        [self.client connectSourceTo:source];
        [self.client connectDestinationTo:destination];
        self.linked=NO;
        __weak LinkWrapper *this=self;
        [self.client setCallback:^(const MIDIPacketList *packets, OSStatus error) {
            [this callbackWithPackets:packets andStatus:error];
        }];
        self.counter=(int32_t *)malloc(sizeof(int32_t));
        *self.counter=0;
        self.active=NO;
        self.decoder=[MIDIDecoder instance];
        self.callback=nil;
    }
    return self;
}

- (void)dealloc {
    free(self.counter);
}

- (MIDIEndPointDescription *)source { return self.client.source; }
- (MIDIEndPointDescription *)destination { return self.client.destination; }

- (NSString *)clientNameField { return self.client.name; }
- (NSString *)sourceNameField { return [self.source description]; }
- (NSString *)destinationNameField { return [self.destination description]; }
- (NSNumber *)activityField { return [NSNumber numberWithBool:self.active]; }


- (void)link {
    if (!self.isLinked) {
        [self.client link];
        self.linked=YES;
    }
}

- (void) unlink {
    if(self.isLinked) {
        [self.client unlink];
        self.linked=NO;
    }
}




- (void)monitor:(const MIDIPacketList *)packets {
    if([self.decoder count]>8192) [self.decoder reset];
    [self.decoder loadPackets:packets];
    if(self.callback) self.callback();
//    if([self.decoder count]==10) {
//        NSArray *messages=[self.decoder messages];
//        MIDIXMLSerialiser *s=[[MIDIXMLSerialiser alloc] initWithMIDIMessages:messages];
//        NSLog(@"%@",[s serialiseToString]);
//    }
}

- (void)callbackWithPackets:(const MIDIPacketList *)packets andStatus:(OSStatus)status {
    NSString *errorMessage=(status==noErr) ? @"" : [NSString stringWithFormat:@"[error %d]",status];
    NSLog(@"Got %ud packets %@ [%d]",packets->numPackets,errorMessage,*self.counter);
    dispatch_async(dispatch_get_main_queue(), ^{
        int32_t new=OSAtomicIncrement32Barrier(self.counter);
        self.active=(new>0);
        NSLog(@"    UP   - %d - %d",*self.counter,new);
        if(new==1) {
            NSLog(@"    FIRE");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MIDIStatusChanged" object:nil];
        }
        [self monitor:packets];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        int32_t new=OSAtomicDecrement32Barrier(self.counter);
        self.active=(new>0);
        NSLog(@"    DOWN - %d - %d",*self.counter,new);
        if(new==0) {
            NSLog(@"    FIRE");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MIDIStatusChanged" object:nil];
        }
    });
    
}

@end
