//
//  MIDILink.h
//  MIDILink
//
//  Created by Julian Porter on 28/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MIDIThing.h"
#import "Endpoint.h"

typedef void(^MIDIActivityCallback)(const MIDIPacketList *packets,OSStatus error);



@interface MIDIClient : NSObject

@property (atomic) MIDIClientRef raw;
@property (copy,nonatomic) NSString *name;
@property (strong,nonatomic) NSDate *isActive;
@property (nonatomic)  MIDIActivityCallback callback;

@property (strong,nonatomic) MIDIEndPointDescription *destination;
@property (atomic) MIDIPortRef outputPort;
@property (strong,nonatomic) MIDIEndPointDescription *source;
@property (atomic) MIDIPortRef inputPort;

- (id)initWithName:(NSString *)name;
- (void)activity:(const MIDIPacketList *)packets withStatus:(OSStatus)error;
- (BOOL)isLink;

- (void)connectSourceTo:(MIDIThing *)source;
- (void)connectDestinationTo:(MIDIThing *)destination;

- (void)link;
- (void)unlink;


@end

@interface MIDIListener : MIDIClient


- (void) connect:(MIDIThing *)thing;
- (void) disconnect;


@end

@interface MIDIInjector : MIDIClient

- (void) connect:(MIDIThing *)thing;
- (void) disconnect;

- (void) inject:(const MIDIPacketList *)packets;

@end
