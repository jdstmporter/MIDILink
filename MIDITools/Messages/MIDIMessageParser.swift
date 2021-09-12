//
//  MIDIMessageParser.swift
//  MIDITools
//
//  Created by Julian Porter on 01/09/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public class MIDIMessageParser : CustomStringConvertible, Sequence {
    public typealias Iterator = MIDIDict.Iterator
    fileprivate let terms : MIDIDict
    
    public init() { self.terms=MIDIDict() }
    public convenience init(_ p: MIDIPacket) throws { try self.init(p.bytes) }
    public init(_ bytes : OffsetArray<UInt8>) throws { self.terms = try MIDICommands.parse(bytes) }
    public init(_ d : MIDIDict) { self.terms=d }
    
    public func append(_ d : MIDIDict) { self.terms.append(d) }
    public func append(_ d : MIDIMessageParser) { self.append(d.terms) }
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


