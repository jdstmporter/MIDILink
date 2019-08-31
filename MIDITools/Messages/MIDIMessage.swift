//
//  MIDIMessage.swift
//  MIDI Utils
//
//  Created by Julian Porter on 15/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI



public protocol MIDIMessageContent {
    var Timestamp : String {get}
    var Command : Serialisable {get}
    var Channel : Serialisable {get}
}

public class MIDIMessageDescription : CustomStringConvertible, Sequence {
    public typealias Iterator = MIDIDict.Iterator
    
    private let terms : MIDIDict
    
    public init(_ p: MIDIPacket) {
        self.terms=MIDICommandTypes.parse(p.bytes) ?? MIDIDict()
    }
    public init(_ d : MIDIDict) {
        self.terms=d
    }
    

    
    public subscript<T>(_ key : MIDITerms) -> T? where T : Serialisable {
        guard let val = (terms.first { $0.key == key})?.value else { return nil }
        return val as? T
    }
    public var count : Int { return terms.count }
    public func makeIterator() -> Iterator { return self.terms.makeIterator() }
    public var description: String { return terms.map { $0.description }.joined(separator:", ") }
    
    public var command : MIDICommandTypes? { return self[.Command] }
    public var channel : UInt8? { return self[.Channel] }
    public var note : MIDINote? { return self[.Note] }
    public var velocity : UInt8? { return self[.Velocity] }
    public var pressure : UInt8? { return self[.Pressure] }
    public var control : UInt8? { return self[.Control] }
    public var value : UInt8? { return self[.Value] }
    public var program : UInt8? { return self[.Program] }
    public var bend : Bend? { return self[.Bend] }
    
}


public class MIDIMessage : MIDIMessageContent, CustomStringConvertible {
    
    public static let CSVHeadings : String = "timestamp, channel, command, byte1, byte 2, \"decoded channel\",\"decoded command\",\":decoded arguments\""
    
    public let packet : MIDIPacket
    private let timebase : TimeStandard!
    public let parsed : MIDIMessageDescription
    public let timestamp : MIDITimeStamp
    
    public init(_ p: MIDIPacket, timebase: TimeStandard? = nil) {
       
        self.packet=p
        self.timebase = timebase
        self.parsed = MIDIMessageDescription(p)
        self.timestamp = p.timeStamp
    }
    
    public init?(_ d : MIDIDict, timebase: TimeStandard? = nil) {
        self.parsed = MIDIMessageDescription(d)
        self.timebase = timebase
        self.timestamp = TimeStandard.now
        guard let bytes = MIDICommandTypes.unparse(self.parsed) else { return nil }
        self.packet = MIDIPacket(timeStamp: self.timestamp, bytes: bytes)
    }
    
    public var Channel : Serialisable { return self.parsed[.Channel] ?? "-" }
    public var Command : Serialisable { return self.parsed[.Command] ?? MIDICommandTypes.UNKNOWN  }
    public var Timestamp : String { return timebase?.convert(packet.timeStamp) ?? "-" }
    public var Raw : [UInt8] { return packet.dataArray }
    

    
    public var description: String { return "\(Timestamp) : \(parsed)" }
    public var shortDescription: String { return parsed.description }
    
    public subscript(field: String) -> String? {
        let mirror=Mirror.init(reflecting: self)
        let match=mirror.children.filter { $0.0! == field }
        if match.count>0 { return (match[0].1 as! String) }
        return nil
    }
}

public class MIDIMessageFactory {
    
    
}






