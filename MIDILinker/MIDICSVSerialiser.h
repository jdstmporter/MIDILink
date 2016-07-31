//
//  MIDICSVSerialiser.h
//  MIDILink
//
//  Created by Julian Porter on 02/05/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIDISerialiser.h"

@interface MIDICSVSerialiser : NSObject < MIDISerialiser>

@property (strong,nonatomic) NSArray *messages;
@property (strong,nonatomic) NSMutableArray *rows;

- (void) serialise;

@end


