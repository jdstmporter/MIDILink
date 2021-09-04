//
//  MIDIMessageTypes.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


public enum MIDICommands : UInt8, MIDIEnumeration {
    
    case NoteOffEvent    = 0x80
    case NoteOnEvent     = 0x90
    case KeyPressure     = 0xa0
    case ControlChange   = 0xb0
    case ProgramChange   = 0xc0
    case ChannelPressure = 0xd0
    case PitchBend       = 0xe0
    case SystemMessage   = 0xf0
    case UNKNOWN         = 0
    
    public  static let names : [MIDICommands:String] = [
        .NoteOffEvent    : "Note Off",
        .NoteOnEvent     : "Note On",
        .KeyPressure     : "Key Pressure",
        .ControlChange   : "Control Change",
        .ProgramChange   : "Program Change",
        .ChannelPressure : "Channel Pressure",
        .PitchBend       : "Pitch Bend",
        .SystemMessage   : "System"
    ]
    

    public static let _unknown : MIDICommands = .UNKNOWN
    public init(_ cmd: UInt8) {
        self = MIDICommands.init(rawValue: cmd & 0xf0) ?? MIDICommands.UNKNOWN
    }
    
    public static func parse(_ bytes: OffsetArray<UInt8>) throws -> MIDIDict {
        guard bytes.count > 0 else { throw MIDIMessageError.NoContent }
        let out = MIDIDict()
        let command=MIDICommands(bytes[0]&0xf0)
        out[.Command]=command
        let channel = bytes[0]&0x0f
        switch command {
        case .NoteOnEvent, .NoteOffEvent:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Note]=MIDINote(bytes[1])
            out[.Velocity]=MIDIVelocity(bytes[2])
        case .KeyPressure:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Note]=MIDINote(bytes[1])
            out[.Pressure]=MIDIPressure(bytes[2])
        case .ProgramChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Program]=MIDIProgram(bytes[1])
        case .ChannelPressure:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Pressure]=MIDIPressure(bytes[1])
        case .PitchBend:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Bend]=Bend(hi: bytes[2], lo: bytes[1])
        case .ControlChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            let cmds=try MIDIControlMessages.parse(bytes.shift(1))
            out.append(cmds)
        case .SystemMessage:
            let cmds = try MIDISystemTypes.parse(bytes.shift(1))
            out.append(cmds)
            if cmds.count>0 {
                let arr = cmds.map { kv in "\(kv.key) = \(kv.value)" }
                out[.InterpretedValue]=arr.joined(separator: ", ")
            }
        default:
            throw MIDIMessageError.UnknownMessage
        }
        return out
    }
    
    
}




