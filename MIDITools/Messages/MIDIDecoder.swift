//
//  MIDIDecoder.swift
//  MIDI Utils
//
//  Created by Julian Porter on 15/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI


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

    


