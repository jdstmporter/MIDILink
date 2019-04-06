//
//  EndpointWrapper.m
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "EndpointWrapper.h"
#import <libkern/OSAtomic.h>
#import "MIDIDecoder.h"



@interface EndpointWrapper ()

@property (nonatomic) int32_t *counter;
@property (nonatomic) BOOL active;
@property (strong,nonatomic) MIDIDecoder *decoder;
@property (nonatomic) DecoderUpdate callback;

- (void) callbackWithPackets:(const MIDIPacketList *)packets andStatus:(OSStatus)status;
- (void)monitor:(const MIDIPacketList *)packets;

@end

@implementation EndpointWrapper

- (instancetype)initWithName:(NSString *)name andEndpoint:(MIDIThing *)endpoint {
    self=[super init];
    if(self) {
        self.listener=[[MIDIListener alloc] initWithName:name];
        [self.listener connect:endpoint];
        NSLog(@"Connected listener to endpoint");
        __weak EndpointWrapper *this=self;
        [self.listener setCallback:^(const MIDIPacketList *packets, OSStatus error) {
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

- (MIDIEndPointDescription *)source { return self.listener.source; }

- (NSString *)clientNameField { return self.listener.name; }
- (NSString *)sourceNameField { return [self.endpoint description]; }
- (NSNumber *)activityField { return [NSNumber numberWithBool:self.active]; }

- (void)monitor:(const MIDIPacketList *)packets {
    if([self.decoder count]>8192) [self.decoder reset];
    [self.decoder loadPackets:packets];
    if(self.callback) self.callback();
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

