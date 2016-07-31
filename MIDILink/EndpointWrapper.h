//
//  EndpointWrapper.h
//  MIDILink
//
//  Created by Julian Porter on 18/07/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDIThing.h"
#import "Endpoint.h"
#import "MIDIDecoder.h"
#import "MIDILink.h"

typedef void(^DecoderUpdate)();

@interface EndpointWrapper : NSObject

@property (strong,nonatomic) MIDIListener *listener;
@property (readonly,nonatomic) MIDIEndPointDescription *endpoint;
@property (readonly,nonatomic) MIDIDecoder *decoder;

@property (readonly,nonatomic) NSString *clientNameField;
@property (readonly,nonatomic) NSString *sourceNameField;
@property (readonly,nonatomic) NSNumber *activityField;


- (instancetype)initWithName:(NSString *)name andEndpoint:(MIDIThing *)endpoint;
- (void) setCallback:(DecoderUpdate)cb;



@end