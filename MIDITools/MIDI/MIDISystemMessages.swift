//
//  MIDISysExMessages.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

public enum MIDISystemTypes : UInt8, MIDIEnumeration {
    case SysEx              = 0xf0
    case TimeCode           = 0xf1
    case SongPosition       = 0xf2
    case SongSelect         = 0xf3
    case Tune               = 0xf4
    case EndSysEx           = 0xf7
    case TimingClock        = 0xf8
    case Start              = 0xfa
    case Continue           = 0xfb
    case Stop               = 0xfc
    case ActiveSensing      = 0xfe
    case SystemReset        = 0xff
    case UNKNOWN            = 0x00
    
    static let names : [MIDISystemTypes:String] = [
        .SysEx : "Exclusive",
        .TimeCode : "Time Code Quarter Frame",
        .SongPosition : "Song Position Pointer",
        .SongSelect : "Song Select",
        .Tune: "Tune Request",
        .EndSysEx : "End Exclusive",
        .TimingClock : "Timing Clock",
        .Start : "Start",
        .Continue : "Continue",
        .Stop : "Stop",
        .ActiveSensing : "Active Sensing",
        .SystemReset : "System Reset"
    ]
    
    public static let _unknown : MIDISystemTypes = .UNKNOWN
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws -> MIDIMessageDescription {
        guard bytes.count > 0 else { throw MIDIMessageError.NoContent }
        
        let command=MIDISystemTypes(bytes[0])
        let out = MIDIMessageDescription()
        out[.SystemCommand] = command
        switch command {
        case .SysEx:
            let cmds = try MIDISysExTypes.parse(bytes.shift(1)) 
            out.append(cmds)
        case .TimeCode:
            let cmds = try MIDITimeCodeTypes.parse(bytes.shift(1))
            out.append(cmds)
        case .Tune, .EndSysEx, .TimingClock, .Start, .Continue, .Stop, .ActiveSensing, .SystemReset :
            break
        case .SongSelect :
            guard bytes.count >= 1 else { throw MIDIMessageError.NoContent }
            out[.Song]=bytes[1]
        case .SongPosition :
            guard bytes.count >= 2 else { throw MIDIMessageError.NoContent }
            out[.SongPositionLO]=bytes[1]
            out[.SongPositionHI]=bytes[2]
        default:
            return MIDIMessageDescription()
        }
        return out
    }
}

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
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws -> MIDIMessageDescription {
        guard bytes.count>0 else { throw MIDIMessageError.NoContent }
        let out=MIDIMessageDescription()
        out[.TimeCode]=MIDITimeCodeTypes(bytes[0]&0xf0)
        out[.Value]=bytes[0]&0x0f
        return out
    }
}




