//
//  MIDITimeStandard.swift
//  MIDIManager
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


public class MIDITimeStandard {
    
    private var start : UInt64
    private var startDate : Date
    private var formatter : DateFormatter
    
    private var numer : UInt64
    private var denom : UInt64
    
    public init?() {
        var tb = mach_timebase_info()
        if mach_timebase_info(&tb) == noErr {
            numer=UInt64(tb.numer)
            denom=UInt64(tb.denom)
            startDate=Date()
            start=mach_absolute_time()
            
            formatter=DateFormatter()
            formatter.locale=Locale.current
            formatter.dateFormat="HH:mm:ss.SSSS"
            formatter.timeZone=TimeZone.current
        }
        else { return nil }
    }
    
    public func convert(_ time : MIDITimeStamp) -> String {
        let nano : UInt64 = (time - start) * numer/denom
        let date = Date(timeInterval: 1.0e-9*Double(nano), since: startDate)
        return formatter.string(from: date)
    }
    
    
}
