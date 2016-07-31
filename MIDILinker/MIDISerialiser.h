//
//  MIDISerialiser.h
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import "MIDIMessage.h"

@protocol MIDISerialiser

- (id) initWithMIDIMessages:(NSArray *)messages;
- (NSData *)serialiseToData;
- (NSString *)serialiseToString;


@end