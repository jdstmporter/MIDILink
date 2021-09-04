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
    
    public  static let names : [MIDISystemTypes:String] = [
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
    
    public static func parse(_ bytes: OffsetArray<UInt8>) throws -> MIDIDict {
        guard bytes.count>0 else { throw MIDIMessageError.NoContent }
        let out=MIDIDict()
        let command=MIDISystemTypes(bytes[0])
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
            break
        }
        return out
    }
}





