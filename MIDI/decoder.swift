//
//  decoder.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public protocol Nameable {
    var str : String { get }
}
extension String : Nameable {
    public var str : String { self }
}
extension UInt8 : Nameable {
    public var str : String { self.description }
}
extension Int16 : Nameable {
    public var str : String { self.description }
}


public protocol MIDIMessageContent {
    var Timestamp : String {get}
    var Command : Nameable {get}
    var Channel : Nameable {get}
}

public protocol NameableEnumeration : CaseIterable, Hashable, Nameable {
    var name : String { get }
    init?(_ : String)
}





extension NameableEnumeration {
    
    public init?(_ name : String) {
        if let item = (Self.allCases.first { $0.name==name }) { self=item } 
        else { return nil }
    }
    public var str : String { name }
}

public protocol StaticNamedEnumeration : NameableEnumeration {
    
    static var names : [Self:String] { get }
}

extension StaticNamedEnumeration {
    
    public var name : String { return Self.names[self] ?? "" }
    
    
}

public enum MIDITerms : NameableEnumeration {
    
    case Command
    case Channel
    case Note
    case Velocity
    case Pressure
    case Control
    case Value
    case InterpretedValue
    case Program
    case Bend
    
    case SystemCommand
    case Song
    case SongPositionLO
    case SongPositionHI
    case TimeCode
    
    case SysExID
    case SysExDeviceID
    case Manufacturer
    case SysExSubID1
    case SysExSubID2
    case SysExData
    
    
    public var name : String { return "\(self)" }
    
}


protocol MIDIEnumeration : RawRepresentable, StaticNamedEnumeration, Comparable where RawValue == UInt8, AllCases == [Self] {
    
    static var _unknown : Self { get }
    static var names : [Self:String] { get }
    var raw : UInt8 { get }
    var name : String { get }
    
    
    init(_ : RawValue)
    init?(_ : String)
    static func has(_ : UInt8) -> Bool
    static func parse(_ : OffsetArray<UInt8>) throws -> MIDIDict
    
}

extension MIDIEnumeration {
    public var raw : UInt8 { return self.rawValue }
    
    
    public func hash(into hasher: inout Hasher) {
        self.rawValue.hash(into: &hasher)
    }
    public var hashValue: Int { return self.rawValue.hashValue }
    public static func has(_ code : UInt8) -> Bool { return Self(code) != Self._unknown }
    
    public init(_ cmd: UInt8) {
        self = Self.init(rawValue: cmd) ?? Self._unknown
    }
    public init?(_ name : String) {
        if let kv = (Self.names.first { $0.value==name }) { self=kv.key }
        else { return nil }
    }
 
    public static var allCases : [Self] { return names.keys.sorted() }
    
    public static func ==(_ l : Self, _ r : Self) -> Bool { return l.raw == r.raw }
    public static func <(_ l : Self, _ r : Self) -> Bool { return l.raw < r.raw }
    
    
    
    
}




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
        self = MIDICommands.init(rawValue: cmd & 0xf0) ?? MIDICommands._unknown
    }
    
    public static func parse(_ b: OffsetArray<UInt8>) throws -> MIDIDict { try MIDIPacketParser(b).parse()
    }
    
    
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
        self.parsed = try MIDIPacketParser(p).parse()
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






public protocol MIDIDecoderInterface {
    func link(decoder d:MIDIDecoder);
    func unlink();
}

public class MIDIDecoderBase : Sequence {
    
    public var action : (() -> Void)!
    internal let lock : NSLock
    public var messages : [MIDIMessage]
    public var count : Int { return messages.count }
    
    public struct Iterator : IteratorProtocol {
        public typealias Element = MIDIMessage
        
        private let packets : [MIDIMessage]
        private var iterator : Array<MIDIMessage>.Iterator
        
        public init(_ p : [MIDIMessage]) {
            packets=p
            iterator=packets.makeIterator()
        }
        
        mutating public func next() -> MIDIMessage? {
            return iterator.next()
        }
    }
    
    
    
    init() throws {
        action = { () in () }
        messages = []
        lock=NSLock()
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(messages)
    }
    
    public subscript(_ row: Int) -> MIDIMessage? {
        var out : MIDIMessage? = nil
        lock.lock()
        if row >= 0 && row < messages.count {
            out=messages[row]
            //debugPrint("Asked for \(field) and got \(out)")
        }
        lock.unlock()
        return out
        
    }
    
    public var content : [MIDIDict] {
        return messages.map { $0.parsed }
    }

}



public class MIDIDummyDecoder : MIDIDecoderBase {
    
    public override init() throws {
        try super.init()
        let timebase=TimeStandard()
        var p=MIDIPacket()
        p.timeStamp=mach_absolute_time()
        p.length=3
        p.data.0=0x90
        p.data.1=60
        p.data.2=63
        var q=MIDIPacket()
        q.timeStamp=mach_absolute_time()
        q.length=3
        q.data.0=0x91
        q.data.1=62
        q.data.2=63
        messages = try [
            MIDIMessage(p,timebase: timebase),
            MIDIMessage(q,timebase: timebase)
        ]
    }
    
    
    
}


public class MIDIDecoder : MIDIDecoderBase {
    
    public static let MIDIDataToDecode=Notification.Name("MIDIDataToDecode")
    
    private let timeStandard : TimeStandard

    public override init() throws {
        timeStandard=TimeStandard()
        try super.init()
    }
    
    public func disconnect() {
        lock.lock()
        action=nil
        lock.unlock()
    }
    
    public func load(packets : [MIDIPacket])  {
        let n=packets.count
        if n>0 {
            let last = messages.last?.timestamp ?? 0
            do {
                let newMessages : [MIDIMessage] = try packets.map { try MIDIMessage($0, timebase: timeStandard) }
                    .filter { $0.timestamp >= last }
                messages.append(contentsOf: newMessages)
                action?()
                NotificationCenter.default.post(name: MIDIDecoder.MIDIDataToDecode, object: nil)
            }
            catch {}
           
        }
    }
    
    
    public func reset() {
        lock.lock()
        messages.removeAll()
        lock.unlock()
    }
    
    public override var count : Int {
        lock.lock()
        let n=messages.count
        lock.unlock()
        return n
    }
    
    public func get(field: String, ofRow row: Int) -> String? {
        var out : String? = nil
        lock.lock()
        if row >= 0 && row < messages.count {
            out=messages[row][field]
            //debugPrint("Asked for \(field) and got \(out)")
        }
        lock.unlock()
        return out
        
    }
    
}

    



