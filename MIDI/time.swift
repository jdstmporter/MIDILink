//
//  time.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

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

    
    public func convert(_ date: Date) -> MIDITimeStamp { (MIDITimeStamp(from: startDate,to: date)*denominator/numerator)+start }
    
    public static var now : MIDITimeStamp { mach_absolute_time() }
    
    
    
}

extension DispatchTime {
    
    static func getTime(fromNowInSeconds n: Float) -> DispatchTime {
        let d=UInt64(n*1.0e9)
        let n=DispatchTime.now()
        return DispatchTime(uptimeNanoseconds: n.uptimeNanoseconds+d)
    }
    
    init() {
        self.init(uptimeNanoseconds: 0)
    }
    
    init(from p : MIDIPacket) {
        self.init(uptimeNanoseconds: p.timeStamp)
    }
    
    public init(fromNowInSeconds n : Float) {
        let d=UInt64(n*1.0e9)
        let n=DispatchTime.now()
        self.init(uptimeNanoseconds: n.uptimeNanoseconds+d)
    }
    
    var timestamp : MIDITimeStamp { return uptimeNanoseconds }
    
}



