//
//  MIDIXMLSerialiser.h
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MidiSerialiser.h"

@interface MIDIXMLSerialiser : NSObject <MIDISerialiser>

@property (strong,nonatomic) NSXMLDocument *document;
@property (strong,nonatomic) NSArray *messages;


- (void) serialise;

@end
