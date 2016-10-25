//
//  TimeBase.m
//  MIDILink
//
//  Created by Julian Porter on 20/09/2016.
//  Copyright © 2016 JP Embedded Solutions. All rights reserved.
//


#import "TimeBase.h"

#include <mach/mach.h>
#include <mach/mach_time.h>

@interface TimeStandard ()
@property (nonatomic) mach_timebase_info_t timebase;
@end


@implementation TimeStandard

- (id)init {
    self=[super init];
    if(self) {
        self.timebase=(mach_timebase_info_t) malloc(sizeof(mach_timebase_info_data_t));
        mach_timebase_info(self.timebase);
        self.startDate=[NSDate date];
        self.start=mach_absolute_time();
        
        self.formatter=[[NSDateFormatter alloc] init];
        self.formatter.locale=[NSLocale currentLocale];
        self.formatter.dateFormat=@"HH:mm:ss.SSSS";
        self.formatter.timeZone=[NSTimeZone defaultTimeZone];
    }
    return self;
}

- (void)dealloc {
    free(self.timebase);
}

- (NSString *)convert:(MIDITimeStamp)time {
    UInt64 nano=(time-self.start) * self.timebase->numer/self.timebase->denom;
    NSDate *date=[NSDate dateWithTimeInterval:1.0e-9*nano sinceDate:self.startDate];
    return [self.formatter stringFromDate:date];
}



@end

