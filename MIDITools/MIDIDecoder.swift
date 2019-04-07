//
//  MIDIDecoder.swift
//  MIDITools
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public typealias MIDIDecoderCallback = () -> ()

public class MIDIDecoder : Sequence  {
    public static let MIDIDataToDecode = Notification.Name("__MIDIDataToDecode")
    
    public struct Iterator : IteratorProtocol {
        public typealias Element = MIDIMessage
        
        private let messages : [MIDIMessage]
        public var it : Array<MIDIMessage>.Iterator
        
        public init(_ decoder: MIDIDecoder) {
            messages=decoder.messages
            it=messages.makeIterator()
        }
        
        public mutating func next() -> Element? {
            return it.next()
        }
        
    }

    
    fileprivate var messages : [MIDIMessage]
    private var timeStandard : MIDITimeStandard
    
    public init() throws {
        messages=[]
        timeStandard = try MIDITimeStandard()
    }
    
    
    public func reset() {
        return DispatchQueue.main.sync {
            self.messages.removeAll()
        }
    }
    
    public func load(_ packets : MIDIPacketList) {
        let nPackets = packets.numPackets
        if nPackets>0 {
            var pkt=packets.packet
            var packet = UnsafeMutablePointer<MIDIPacket>(&pkt)
            (0..<nPackets).forEach { _ in
                let message = MIDIMessage(packet.pointee, timebase: timeStandard)
                messages.append(message)
                packet=MIDIPacketNext(packet)
            }
            NotificationCenter.default.post(name: MIDIDecoder.MIDIDataToDecode, object: nil)
        }
    }
    
    public func get(field: String, ofRow row: Int) -> String? {
        return DispatchQueue.main.sync {
            if (0..<self.count).contains(row) {
                return self.messages[row][field]
            }
            else { return nil }
        }
    }
    
    public var count : Int { return DispatchQueue.main.sync { return messages.count } }
    public __consuming func makeIterator() -> Iterator {
        return DispatchQueue.main.sync { return Iterator(self) }
    }
    
    
}
