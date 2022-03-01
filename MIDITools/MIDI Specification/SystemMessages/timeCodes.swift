//
//  timeCodes.swift
//  MIDIUtils
//
//  Created by Julian Porter on 02/09/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation

public enum MIDITimeCodeTypes : UInt8, MIDIEnumeration {
    case LoFrames = 0x00
    case HiFrames = 0x10
    case LoSeconds = 0x20
    case HiSeconds = 0x30
    case LoMinutes = 0x40
    case HiMinutes = 0x50
    case LoHours = 0x60
    case HiHours = 0x70
    case UNKNOWN = 0xff
    
    
    public static let names : [MIDITimeCodeTypes:String] = [
        .LoFrames : "Frames (Lo nibble)",
        .HiFrames : "Frames (Hi nibble)",
        .LoSeconds : "Seconds (Lo nibble)",
        .HiSeconds : "Seconds (Hi nibble)",
        .LoMinutes : "Minutes (Lo nibble)",
        .HiMinutes : "Minutes (Hi nibble)",
        .LoHours : "Hours (Lo nibble)",
        .HiHours : "Hours (Hi nibble)"
        
    ]
    public static let lengths : [MIDITimeCodeTypes:Int] = [:]
    public static let _unknown : MIDITimeCodeTypes = .UNKNOWN
    
    
    public init(_ cmd: UInt8) {
        self = MIDITimeCodeTypes.init(rawValue: cmd & 0xf0) ?? MIDITimeCodeTypes._unknown
    }
        
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws -> MIDIDict {
        guard bytes.count>0 else { throw MIDIMessageError(reason: .NoContent) }
        let out=MIDIDict()
        out[.TimeCode]=MIDITimeCodeTypes(bytes[0]&0xf0)
        out[.Value]=bytes[0]&0x0f
        return out
    }
}
