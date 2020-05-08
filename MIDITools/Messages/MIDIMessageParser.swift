//
//  MIDIMessageParser.swift
//  MIDITools
//
//  Created by Julian Porter on 01/09/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
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



public class MIDIMessageParser : CustomStringConvertible, Sequence {
    public typealias Iterator = MIDIDict.Iterator
    
    fileprivate let terms : MIDIDict
    
    public init() {
        self.terms=MIDIDict()
    }
    
    public convenience init(_ p: MIDIPacket) throws {
        try self.init(p.bytes)
    }
    public init(_ bytes : OffsetArray<UInt8>) throws {
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
            out[.Control]=try MIDIControlMessage(bytes.shift(1))
        case .SystemMessage:
            let cmds = try MIDISystemMessage(bytes.shift(1)).body
            out.append(cmds)
        default:
            throw MIDIMessageError.UnknownMessage
        }
        self.terms=out
    }
    public init(_ d : MIDIDict) {
        self.terms=d
    }
    
    public func append(_ d : MIDIDict) {
        self.terms.append(d)
    }
    public func append(_ d : MIDIMessageParser) {
        self.append(d.terms)
    }
    
    public var dict : MIDIDict { terms }
    
    public subscript<T>(_ key : MIDITerms) -> T? where T : Nameable {
        get {
            guard let val = (terms.first { $0.key == key})?.value else { return nil }
            return val as? T
        }
        set {
            terms[key] = newValue
        }
    }
    public var count : Int { terms.count }
    public func makeIterator() -> Iterator { self.terms.makeIterator() }
    public var description: String { terms.map { $0.description }.joined(separator:", ") }
    
    public var command : MIDICommands? { self[.Command] }
    public var channel : UInt8? { self[.Channel] }
    public var note : MIDINote? { self[.Note] }
    public var velocity : MIDIVelocity? { self[.Velocity] }
    public var pressure : MIDIPressure? { self[.Pressure] }
    public var control : MIDIControlMessages? { self[.Control] }
    public var value : UInt8? { self[.Value] }
    public var program : MIDIProgram? { self[.Program] }
    public var bend : Bend? { self[.Bend] }
    
}


