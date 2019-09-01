//
//  MIDIMessageDescription.swift
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

public class MIDIMessageDescription : CustomStringConvertible, Sequence {
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
        let command=MIDICommandTypes(bytes[0]&0xf0)
        out[.Command]=command
        let channel = bytes[0]&0x0f
        switch command {
        case .NoteOnEvent, .NoteOffEvent:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Note]=MIDINote(bytes[1])
            out[.Velocity]=bytes[2]
        case .KeyPressure:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Note]=MIDINote(bytes[1])
            out[.Pressure]=bytes[2]
        case .ProgramChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Program]=bytes[1]
        case .ChannelPressure:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Pressure]=bytes[1]
        case .PitchBend:
            guard bytes.count >= 3 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Bend]=Bend(hi: bytes[2], lo: bytes[1])
        case .ControlChange:
            guard bytes.count >= 2 else { throw MIDIMessageError.BadPacket }
            out[.Channel]=channel
            out[.Control]=try MIDIControlMessage(bytes.shift(1))
        case .SystemMessage:
            let cmds = try MIDISystemTypes.parse(bytes.shift(1))
            cmds.forEach { out[$0.key] = $0.value }
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
    public func append(_ d : MIDIMessageDescription) {
        self.append(d.terms)
    }
    
    public func bytes() throws -> [UInt8] {
        guard let command = self.command, let channel = self.channel else { throw MIDIMessageError.NoCommand }
        var bytes : [UInt8] = []
        bytes.append(command.raw | channel)
        
        switch command {
        case .NoteOnEvent, .NoteOffEvent:
            guard let note  = self.note, let velocity = self.velocity else { throw MIDIMessageError.NoNote }
            bytes.append(note.code)
            bytes.append(velocity)
        case .KeyPressure:
        guard let note  = self.note, let pressure = self.pressure else { throw MIDIMessageError.NoNote }
        bytes.append(note.code)
        bytes.append(pressure)
        case .ProgramChange:
            guard let value = self.program else { throw MIDIMessageError.NoValue }
            bytes.append(value)
        case .ChannelPressure:
            guard let value = self.pressure else { throw MIDIMessageError.NoValue }
            bytes.append(value)
        case .PitchBend:
            guard let b = self.bend else { throw MIDIMessageError.BadBend }
            bytes.append(b.lo)
            bytes.append(b.hi)
        case .ControlChange:
            guard let control = self.control else { throw MIDIMessageError.NoValue }
            bytes.append(control.raw)
            if let v = self.value { bytes.append(v) }
        default:
            throw MIDIMessageError.UnknownMessage
        }
        return bytes
    }
    
    public subscript<T>(_ key : MIDITerms) -> T? where T : Serialisable {
        get {
            guard let val = (terms.first { $0.key == key})?.value else { return nil }
            return val as? T
        }
        set {
            terms[key] = newValue
        }
    }
    public var count : Int { return terms.count }
    public func makeIterator() -> Iterator { return self.terms.makeIterator() }
    public var description: String { return terms.map { $0.description }.joined(separator:", ") }
    
    public var command : MIDICommandTypes? { return self[.Command] }
    public var channel : UInt8? { return self[.Channel] }
    public var note : MIDINote? { return self[.Note] }
    public var velocity : UInt8? { return self[.Velocity] }
    public var pressure : UInt8? { return self[.Pressure] }
    public var control : MIDIControlMessages? { return self[.Control] }
    public var value : UInt8? { return self[.Value] }
    public var program : UInt8? { return self[.Program] }
    public var bend : Bend? { return self[.Bend] }
    
}
