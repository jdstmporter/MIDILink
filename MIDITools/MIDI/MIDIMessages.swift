//
//  MIDIMessageTypes.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public enum MIDICommandTypes : UInt8, MIDIEnumeration {
    case NoteOffEvent    = 0x80
    case NoteOnEvent     = 0x90
    case KeyPressure     = 0xa0
    case ControlChange   = 0xb0
    case ProgramChange   = 0xc0
    case ChannelPressure = 0xd0
    case PitchBend       = 0xe0
    case SystemMessage   = 0xf0
    case UNKNOWN         = 0
    
     static let names : [MIDICommandTypes:String] = [
        .NoteOffEvent    : "Note Off",
        .NoteOnEvent     : "Note On",
        .KeyPressure     : "Key Pressure",
        .ControlChange   : "Control Change",
        .ProgramChange   : "Program Change",
        .ChannelPressure : "Channel Pressure",
        .PitchBend       : "Pitch Bend",
        .SystemMessage   : "System"
    ]
    
    static let labels : [MIDICommandTypes:[MIDITerms]] = [
        .NoteOffEvent    : [.Note,.Velocity],
        .NoteOnEvent     : [.Note,.Velocity],
        .KeyPressure     : [.Note,.Pressure],
        .ControlChange   : [.Channel,.Value],
        .ProgramChange   : [.Program],
        .ChannelPressure : [.Pressure],
        .PitchBend       : [.Bend],
        .SystemMessage   : []
    ]
    
    
    public static func parse(_ bytes : OffsetArray<UInt8>) -> MIDIDict? {
        guard bytes.count > 0 else { return  nil }
        let out = MIDIDict() 
        let command=MIDICommandTypes(bytes[0]&0xf0)
         out[.Command]=command
        let channel = bytes[0]&0x0f
        let labels = MIDICommandTypes.labels[command] ?? []
        switch command {
            case .NoteOnEvent, .NoteOffEvent, .KeyPressure:
                guard bytes.count >= 3 else { return nil }
                let note=MIDINote(bytes[1])
                out[.Channel]=channel
                out[labels[0]]=note 
                out[labels[1]]=bytes[2]
            case .ProgramChange, .ChannelPressure:
                guard bytes.count >= 2 else { return nil }
                out[.Channel]=channel
                out[labels[0]]=bytes[1]
            case .PitchBend:
                guard bytes.count >= 3 else { return nil }
                out[.Channel]=channel
                out[.Bend]=Bend(hi: bytes[2], lo: bytes[1])
            case .ControlChange:
                guard bytes.count >= 3 else { return nil }
                out[.Channel]=channel
                out[labels[0]]=bytes[1]
                out[labels[1]]=bytes[2]
            case .SystemMessage:
                guard let cmds = MIDISystemTypes.parse(bytes.shift(1)) else { return nil }
                cmds.forEach { out[$0.key] = $0.value }
            default:
                return nil
            }
        return out
    }
    
    public static func unparse(_ dict : MIDIMessageDescription) -> [UInt8]? {
        guard let command = dict.command, let channel = dict.channel else { return nil }
        var bytes : [UInt8] = []
        bytes.append(command.raw | channel)
        
        guard let labels = MIDICommandTypes.labels[command] else { return nil }
        switch command {
        case .NoteOnEvent, .NoteOffEvent, .KeyPressure:
            guard let note  = dict.note, let other : UInt8 = dict[labels[1]] else { return nil }
            bytes.append(note.code)
            bytes.append(other)
        case .ProgramChange, .ChannelPressure:
            guard let value : UInt8 = dict[labels[0]] else { return nil }
            bytes.append(value)
        case .PitchBend:
            guard let b = dict.bend else { return nil }
            bytes.append(b.lo)
            bytes.append(b.hi)
        case .ControlChange:
            guard let control = dict.control, let value = dict.value else { return nil }
            bytes.append(control)
            bytes.append(value)
        default:
            return nil
        }
        return bytes
    }
    
    
    public static let _unknown : MIDICommandTypes = .UNKNOWN
    public init(_ cmd: UInt8) {
        self = MIDICommandTypes.init(rawValue: cmd & 0xf0) ?? MIDICommandTypes._unknown
    }
    
    
}



public enum MIDIMessageValueType {
    case Nibble
    case Byte
    case Word
    case OnOff64
    case OnOff127
    case Legato
    case Null
    case NA
    case ON
    case OFF
    case TimeCode
    case SysEx
}

public let MIDIMessageValueTypeLength : [MIDIMessageValueType : Int?] = [
    .Nibble : 1,
    .Byte: 1,
    .Word: 2,
    .OnOff64: 1,
    .OnOff127: 1,
    .Legato: 1,
    .Null: 0,
    .NA: 0,
    .ON: 0,
    .OFF: 0,
    .TimeCode: 1,
    .SysEx : nil
]
