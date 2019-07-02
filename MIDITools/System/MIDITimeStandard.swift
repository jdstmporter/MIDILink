//
//  MIDITimeStandard.swift
//  MIDI Utils
//
//  Created by Julian Porter on 15/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI
import CoreServices



extension MIDITimeStamp {
    public init(from: Date, to: Date) {
        self.init(to.timeIntervalSince(from)*1.0e9)
    }
    public func intervalSince(_ t: MIDITimeStamp) -> MIDITimeStamp {
        let d = t.distance(to: self)
        return (d>=0) ? MIDITimeStamp(d) : self
    }
}

public class TimeStandard {
        
    private let startDate : Date
    private let start : MIDITimeStamp
    private let formatter : DateFormatter
    
    private let numerator : MIDITimeStamp
    private let denominator : MIDITimeStamp
    
    public init() {
        
        var p = mach_timebase_info()
        mach_timebase_info(&p)
        numerator=MIDITimeStamp(p.numer)
        denominator=MIDITimeStamp(p.denom)
        
        
        startDate=Date()
        start=mach_absolute_time()
        
        formatter=DateFormatter()
        formatter.locale=Locale.current
        formatter.dateFormat="HH:mm:ss.SSSS"
        formatter.timeZone=TimeZone.current
    }
    
    public func convert(_ time: MIDITimeStamp) -> String {
        let nano : MIDITimeStamp = time.intervalSince(start)*numerator/denominator
        let date=Date(timeInterval: 1.0e-9*Double(nano), since: startDate)
        return formatter.string(from: date)
    }
    
    public func convert(_ date: Date) -> MIDITimeStamp {
        return (MIDITimeStamp(from: startDate,to: date)*denominator/numerator)+start
    }
    
    public static var now : MIDITimeStamp {
        return mach_absolute_time()
    }
    
}
