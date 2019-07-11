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
    public typealias Iterator = Array<KVPair>.Iterator
    
    private let terms : [KVPair]
    
    public init(_ p: MIDIPacket) {
        self.terms=MIDICommandTypes.parse(p.bytes) ?? []
    }
    
    public subscript(_ key : String) -> Serialisable? {
        return (terms.first { $0.key == key})?.value
    }
    public var count : Int { return terms.count }
    public func makeIterator() -> Iterator { return self.terms.makeIterator() }
    public var description: String { return terms.map { $0.description }.joined(separator:", ") }
    
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
    
    public var Channel : Serialisable { return self.parsed["Channel"] ?? "-" }
    public var Command : Serialisable { return self.parsed["Command"] ?? MIDICommandTypes.UNKNOWN  }
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






