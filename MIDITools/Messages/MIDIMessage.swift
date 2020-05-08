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
    var Command : Nameable {get}
    var Channel : Nameable {get}
}



public class MIDIMessage : MIDIMessageContent, CustomStringConvertible {
    
    public static let CSVHeadings : String = "timestamp, channel, command, byte1, byte 2, \"decoded channel\",\"decoded command\",\":decoded arguments\""
    
    public let packet : MIDIPacket
    private let timebase : TimeStandard!
    public let parsed : MIDIDict
    public let timestamp : MIDITimeStamp
    
    public init(_ p: MIDIPacket, timebase: TimeStandard? = nil) throws {
       
        self.packet=p
        self.timebase = timebase
        self.parsed = try MIDIMessageParser(p).dict
        self.timestamp = p.timeStamp
    }
    
    
    public var Channel : Nameable { self.parsed[.Channel] ?? "-" }
    public var Command : Nameable { self.parsed[.Command] ?? MIDICommands.UNKNOWN  }
    public var Timestamp : String { timebase?.convert(packet.timeStamp) ?? "-" }
    public var Raw : [UInt8] { packet.dataArray }
    
    public static let exclude : [MIDITerms] = [.Command, .Channel]

    
    public var description: String { "\(Timestamp) : \(parsed)" }
    public var shortDescription: String { parsed.description }
    public var parameters: String {
        parsed.compactMap { kv in
            guard !MIDIMessage.exclude.contains(kv.key) else {return nil }
            return kv.value.str
        }.joined(separator: ", ")
    }
    
    public subscript(field: String) -> String? {
        let mirror=Mirror.init(reflecting: self)
        let match=mirror.children.filter { $0.0! == field }
        if match.count>0 { return (match[0].1 as! String) }
        return nil
    }
}




