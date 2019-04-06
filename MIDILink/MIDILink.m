//
//  MIDILink.m
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDILink.h"


void MIDIProcessingFunction(const MIDIPacketList *packets,void *clientRef,void *sourceRef) {

    MIDIClient *client=(__bridge MIDIClient *)clientRef;
    OSStatus error=(client.destination==nil)? noErr : MIDISend(client.outputPort,client.destination.object,packets);
    dispatch_async(dispatch_get_main_queue(), ^{
        client.callback(packets,error);
    });
    
}

void MIDINotifyFunction(const MIDINotification *message,void *clientRef) {
    //MIDIClient *client=(__bridge MIDIClient *)clientRef;
    NSLog(@"MIDI notification #%d of size %ud",message->messageID,message->messageSize);
}

@implementation MIDIClient

- (id)initWithName:(NSString *)name {
    self=[super init];
    if(self) {
        self.name=name;
        MIDIClientRef raw;
        OSStatus error=MIDIClientCreate((CFStringRef)CFBridgingRetain(name), MIDINotifyFunction,(__bridge void * _Nullable)(self), &raw);
        if(error!=noErr) [MIDIThing errorWithCode:error andDescription:[NSString stringWithFormat:@"Cannot create application with name %@",self.name]];
        self.raw=raw;
        __weak MIDIClient *this=self;
        self.callback=^(const MIDIPacketList *p,OSStatus e) {
            [this activity:p withStatus:e];
        };
        self.destination=nil;
        self.outputPort=0;
    }
    return self;
}

- (void)dealloc {
    MIDIClientDispose(self.raw);
    MIDIPortDispose(self.inputPort);
    MIDIPortDispose(self.outputPort);

}

- (BOOL)isLink {
    return NO;
}

- (void)activity:(const MIDIPacketList *)packets withStatus:(OSStatus)error {
    NSString *errorMessage=(error==noErr) ? @"" : [NSString stringWithFormat:@"[error %d]",error];
    NSLog(@"Got %ud packets %@",packets->numPackets,errorMessage);
    self.isActive=[NSDate date];
}

- (void)connectDestinationTo:(MIDIThing *)destination {
    self.destination=(destination==nil) ? nil : [[MIDIEndPointDescription alloc] initWithThing:destination];
    MIDIPortRef port;
    CFStringRef name=(CFStringRef)CFBridgingRetain((self.destination==nil) ? @"-" :self.destination.Name);
    OSStatus error=MIDIOutputPortCreate(self.raw, name, &port);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot create output port"];
    CFRelease(name);
    self.outputPort=port;
}

- (void)connectSourceTo:(MIDIThing *)source {
    self.source=(source==nil) ? nil : [[MIDIEndPointDescription alloc] initWithThing:source];
    MIDIPortRef port;
    CFStringRef name=(CFStringRef)CFBridgingRetain((self.source==nil) ? @"-" :self.source.Name);
    OSStatus error=MIDIInputPortCreate(self.raw, name,MIDIProcessingFunction,(__bridge void *)self,&port);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot create input port"];
    CFRelease(name);
    self.inputPort=port;
}

- (void)link {
    OSStatus error=MIDIPortConnectSource(self.inputPort,self.source.object,NULL);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot link input port"];
}

- (void)unlink {
    OSStatus error=MIDIPortDisconnectSource(self.inputPort, self.source.object);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot unlink input port"];
}



@end



@implementation MIDIListener



- (void)connect:(MIDIThing *)thing {
    [self connectSourceTo:thing];
    [self connectDestinationTo:nil];
    [self link];
}

- (void)disconnect {
    [self unlink];
}


@end

@implementation MIDIInjector

- (void)connect:(MIDIThing *)thing {
    self.source=nil;
    [self connectDestinationTo:thing];
}

- (void)disconnect {
    OSStatus error=MIDIPortDispose(self.outputPort);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"Cannot dispose of output port"];
}

- (void)inject:(const MIDIPacketList *)packets {
    OSStatus error=MIDISend(self.outputPort,self.destination.object,packets);
    if(error!=noErr) [MIDIThing errorWithCode:error andDescription:@"CError sending packets"];
}

@end
