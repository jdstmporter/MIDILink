//
//  TimeBase.h
//  MIDILink
//
//  Created by Julian Porter on 20/09/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>


@interface TimeStandard : NSObject

@property (nonatomic) UInt64 start;
@property (strong,nonatomic) NSDate *startDate;
@property (strong,nonatomic) NSDateFormatter *formatter;

- (id) init;
- (NSString *)convert:(MIDITimeStamp)time;

@end
