//
//  MIDIDecoder.h
//  MIDILink
//
//  Created by Julian Porter on 30/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MIDIMessage.h"



@interface MIDIDecoder : NSObject

@property (strong,nonatomic) NSMutableArray *messages;
@property (strong,nonatomic) TimeStandard *timeStandard;

- (void) loadPackets:(const MIDIPacketList *)packets;

- (instancetype)init;
- (void) reset;
+ (MIDIDecoder *)instance;


- (NSUInteger)count;
- (NSString *) field:(NSString *)field ofRow:(NSInteger)row;

@end

@protocol MIDIDecoderConsumer

- (void) setDecoder:(MIDIDecoder *)decoder;
- (void) update;
- (void) unsetDecoder;

@end
