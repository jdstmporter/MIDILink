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



public class MIDIMessage : MIDIMessageContent, CustomStringConvertible {
    
    public static let CSVHeadings : String = "timestamp, channel, command, byte1, byte 2, \"decoded channel\",\"decoded command\",\":decoded arguments\""
    
    public let packet : MIDIPacket
    private let timebase : TimeStandard!
    public let parsed : MIDIMessageDescription 
    public let timestamp : MIDITimeStamp
    
    public init(_ p: MIDIPacket, timebase: TimeStandard? = nil) throws {
       
        self.packet=p
        self.timebase = timebase
        self.parsed = try MIDIMessageDescription(p)
        self.timestamp = p.timeStamp
    }
    
    public init(_ d : MIDIMessageDescription, timebase: TimeStandard? = nil) throws {
        self.parsed = d
        self.timebase = timebase
        self.timestamp = TimeStandard.now
        self.packet = try MIDIPacket(timeStamp: self.timestamp, bytes: self.parsed.bytes())
    }
    
    public convenience init(_ d : MIDIDict, timebase: TimeStandard? = nil) throws {
        try self.init(MIDIMessageDescription(d),timebase: timebase)
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




