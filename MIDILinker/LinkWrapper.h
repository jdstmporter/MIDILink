//
//  LinkWrapper.h
//  MIDILink
//
//  Created by Julian Porter on 30/04/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDILink.h"
#import "MIDIThing.h"
#import "Endpoint.h"
#import "MIDIDecoder.h"


typedef void(^DecoderUpdate)();

@interface LinkWrapper : NSObject

@property (strong,nonatomic) MIDIClient *client;
@property (readonly,nonatomic) MIDIEndPointDescription *source;
@property (readonly,nonatomic) MIDIEndPointDescription *destination;
@property (getter=isLinked,atomic) BOOL linked;
@property (readonly,nonatomic) MIDIDecoder *decoder;

@property (readonly,nonatomic) NSString *clientNameField;
@property (readonly,nonatomic) NSString *sourceNameField;
@property (readonly,nonatomic) NSString *destinationNameField;
@property (readonly,nonatomic) NSNumber *activityField;


- (instancetype)initWithName:(NSString *)name source:(MIDIThing *)source andDestination:(MIDIThing *)destination;
- (void) link;
- (void) unlink;
- (void) setCallback:(DecoderUpdate)cb;



@end
