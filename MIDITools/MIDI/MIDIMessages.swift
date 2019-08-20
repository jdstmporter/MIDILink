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
    
    static let labels : [MIDICommandTypes:[String]] = [
        .NoteOffEvent    : ["Note","Velocity"],
        .NoteOnEvent     : ["Note","Velocity"],
        .KeyPressure     : ["Note","Pressure"],
        .ControlChange   : ["Command","Value"],
        .ProgramChange   : ["Program"],
        .ChannelPressure : ["Pressure"],
        .PitchBend       : ["Bend"],
        .SystemMessage   : []
    ]
    
    public static func parse(_ bytes : OffsetArray<UInt8>) -> MIDIDict? {
        guard bytes.count > 0 else { return  nil }
        let out = MIDIDict()
        let command=MIDICommandTypes(bytes[0]&0xf0)
         out["Command"]=command
        let channel = bytes[0]&0x0f
        let labels = MIDICommandTypes.labels[command] ?? []
        switch command {
            case .NoteOnEvent, .NoteOffEvent, .KeyPressure:
                guard bytes.count >= 3 else { return nil }
                let note=MIDINote(bytes[1])
                out["Channel"]=channel
                out[labels[0]]="\(note.name) [\(note.code)]"
                out[labels[1]]=bytes[2]
            case .ProgramChange, .ChannelPressure:
                guard bytes.count >= 2 else { return nil }
                out["Channel"]=channel
                out[labels[0]]=bytes[1]
            case .PitchBend:
                guard bytes.count >= 3 else { return nil }
                out["Channel"]=channel
                out[labels[0]]=UInt16(bytes[2])<<8 + UInt16(bytes[1])
            case .ControlChange:
                guard bytes.count >= 3 else { return nil }
                out["Channel"]=channel
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
