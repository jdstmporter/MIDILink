//
//  MIDIJSONSerialiser.h
//  MIDILink
//
//  Created by Julian Porter on 03/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDISerialiser.h"

@interface MIDIJSONSerialiser : NSObject < MIDISerialiser>

@property (strong,nonatomic) NSArray *messages;
@property (strong,nonatomic) NSMutableArray *objects;

- (void) serialise;

@end