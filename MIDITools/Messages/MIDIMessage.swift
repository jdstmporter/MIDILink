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

public class OrderedDictionary<K,V> : Sequence where K : Hashable, K : CustomStringConvertible {
    fileprivate var dict : [K:V] = [:]
    fileprivate var order : [K] = []
    
    public struct Iterator : IteratorProtocol {
        public typealias Element=KVPair<K,V>
        private let dict : [K:V]
        private var it : Array<K>.Iterator
        
        public init(_ d : OrderedDictionary) {
            dict=d.dict
            it=d.order.makeIterator()
        }
        
        public mutating func next() -> OrderedDictionary<K, V>.Iterator.Element? {
            guard let k = it.next() else { return nil }
            guard let v = dict[k] else { return nil }
            return KVPair(k,v)
        }
        
    }
    
    public var count : Int { return order.count }
    public func at(_ idx : Int) -> KVPair<K,V>? {
        guard idx>=0 && idx<count else { return nil }
        let k=order[idx]
        guard let v = dict[k] else { return nil }
        return KVPair(k,v)
    }
    
    public subscript(_ key : K) -> V? {
        get { return dict[key] }
        set {
            if let value=newValue {
                if !order.contains(key) { order.append(key) }
                dict[key]=value
            }
            else {
                if order.contains(key) { order.removeAll { $0==key } }
                dict.removeValue(forKey: key)
            }
        }
    }
    
    public __consuming func makeIterator() -> OrderedDictionary<K, V>.Iterator {
        return Iterator(self)
    }
}


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
    
    public init(_ d : MIDIDict, timebase: TimeStandard? = nil) {
        self.parsed = MIDIMessageDescription(d)
        self.timebase = timebase
        self.timestamp = TimeStandard.now
        
        self.packet = MIDIPacket() // needs to be filled in
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

public class MIDIMessageFactory {
    
    
}






