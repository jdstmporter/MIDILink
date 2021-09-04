//
//  packets.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

func copyData<T>(_ p : UnsafeMutablePointer<T>, _ b : [T]) {
    let pp = UnsafeMutableBufferPointer<T>(start:p,count:b.count)
    (0..<b.count).forEach { pp[$0] = b[$0] }
}

func assign<T>(_ p : UnsafeMutablePointer<T>, _ b : [T]) {
    var bb=b
    p.initialize(from: &bb[0], count: b.count)
}

func conv(length : Int,_ p : UnsafeMutableRawPointer) -> UnsafeMutableBufferPointer<UInt8> {
    let b = p.bindMemory(to: UInt8.self, capacity: length)
    return UnsafeMutableBufferPointer(start : b,count : length)
}

public class OffsetArray<T> {
    private var array: Array<T>
    private let offset : Int
    
    public init(_ array : Array<T>, offset : UInt = 0) {
        self.array = array
        self.offset = Int(offset)
    }
    
    public func shift(_ inc : UInt) -> OffsetArray<T> {
        return OffsetArray<T>(array, offset: UInt(offset)+inc)
    }
    
    public subscript(_ idx : Int) -> T { return array[offset+idx] }
    public var count : Int { return array.count-offset }
    
}


extension MIDIPacket {
 
    var dataArray : [UInt8] {
        get {
            var d=self.data
            return Array<UInt8>(conv(length: Int(self.length),&d))
        }
        set(a) {
            let p = conv(length: a.count, &(self.data))
            for kv in a.enumerated() { p[kv.offset] = kv.element }
            self.length=UInt16(a.count)
        }
    }
    
    var bytes : OffsetArray<UInt8> { return OffsetArray(dataArray) }
    
    var dataPointer : UnsafeMutablePointer<UInt8>? {
        var d=self.data
        return conv(length:Int(self.length),&d).baseAddress
    }

}

extension MIDIPacketList {
    
    public var packets : [MIDIPacket] {
        let n=self.numPackets
        if n==0 { return [] }

        var out : [MIDIPacket] = []
        var packet  = self.packet
        (0..<(n)).forEach { (index) in
            out.append(packet)
            packet=MIDIPacketNext(&packet).pointee
        }
        return out
    }
    
    public func filter(realTime r: Bool) -> [MIDIPacket] {
        let n=self.numPackets
        if n==0 { return [] }
        
        var out : [MIDIPacket] = []
        var packet  = self.packet
        (0..<(n)).forEach { (index) in
            if !r || packet.data.0 < 0xf8 { out.append(packet) }
            packet=MIDIPacketNext(&packet).pointee
        }
        return out
    }
    
    public init(packets : [MIDIPacket]) {
        var list=MIDIPacketList()
        var ptr=MIDIPacketListInit(&list)
        packets.forEach { (p) in
            //let bytes = { (b : UnsafePointer<UInt8>) in b }(p.dataArray)
            ptr=MIDIPacketListAdd(&list, 65536, ptr, p.timeStamp, Int(p.length), p.dataPointer!)
            debugPrint("Packet @ time \(p.timeStamp) bytes \(p.dataArray) npackets \(list.numPackets)")
        }
        self=list
    }
 
    public static func Make(from packets : [MIDIPacket]) -> MIDIPacketList {
        
        var list=MIDIPacketList()
        var ptr=MIDIPacketListInit(&list)
        packets.forEach { (p) in
            //let bytes = { (b : UnsafePointer<UInt8>) in b }(p.dataArray)
            ptr=MIDIPacketListAdd(&list, 65536, ptr, p.timeStamp, Int(p.length), p.dataPointer!)
            debugPrint("Packet @ time \(p.timeStamp) bytes \(p.dataArray) npackets \(list.numPackets)")
        }
        return list
    }
}

public extension MIDIPacket {
    
    init(timeStamp t: MIDITimeStamp,bytes b: [UInt8],length l: UInt16) {
        self.init()
        timeStamp=t
        self.length=l
        let bytes=Array(b.prefix(Int(l)))
        copyData(&self.data.0,bytes)
    }
    init(timeStamp t: MIDITimeStamp,bytes b: [UInt8]) {
        self.init(timeStamp: t,bytes: b,length: numericCast(b.count))
    }

}

