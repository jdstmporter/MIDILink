//
//  parser.swift
//  MIDI
//
//  Created by Julian Porter on 23/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public enum MIDIMessageError : Error {
    case NoContent
    case BadPacket
    case CannotParseSystemMessage
    case UnknownMessage
    case NoCommand
    case NoNote
    case NoValue
    case BadBend
}



public protocol PacketParser {
    
    init(_ bytes: OffsetArray<UInt8>)
    func parse() throws -> MIDIDict
}

class MIDIPacketParser: PacketParser {
    
    let bytes : OffsetArray<UInt8>
    
    private func bend(hi: UInt8, lo: UInt8) -> Int16 {
        let v : UInt16 = (numericCast(hi) << 7) | numericCast(lo)
        return numericCast(v & 0x3fff) - 8192
    }
    
    init(_ p : MIDIPacket) { bytes=p.bytes }
    init(_ _bytes: [UInt8]) { bytes = OffsetArray(_bytes) }
    required init(_ _bytes: OffsetArray<UInt8>) { bytes=_bytes }
    
    func parse() throws -> MIDIDict {
        guard bytes.count>0 else { throw MIDIMessageError.NoContent }
        let output = MIDIDict()
        
        let channel=bytes[0]&0x0f
        
        let command=MIDICommands(bytes[0]&0xf0)
        output[.Command]=command
        
        switch command {
        case .NoteOnEvent, .NoteOffEvent:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Note]=bytes[1]
            output[.Velocity]=bytes[2]
        case .KeyPressure:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Note]=bytes[1]
            output[.Pressure]=bytes[2]
        case .ProgramChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Program]=bytes[1]
        case .ChannelPressure:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Pressure]=bytes[1]
        case .PitchBend:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Bend]=bend(hi: bytes[2], lo: bytes[1])
        case .ControlChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            output[.Channel]=channel
            output[.Control]="Command = \(bytes[1]) Value = \(bytes[2])"
        case .SystemMessage:
            output[.SysExData]="SysEx"
        default:
            throw MIDIMessageError.UnknownMessage
        }
        return output
    }
    
}
