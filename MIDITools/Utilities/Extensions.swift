//
//  Extensions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI




extension DispatchTime {
    
    static func getTime(fromNowInSeconds n: Float) -> DispatchTime {
        let d=UInt64(n*1.0e9)
        let n=DispatchTime.now()
        return DispatchTime(uptimeNanoseconds: n.uptimeNanoseconds+d)
    }
    
    init() {
        self.init(uptimeNanoseconds: 0)
    }
    
    init(from p : MIDIPacket) {
        self.init(uptimeNanoseconds: p.timeStamp)
    }
    
    public init(fromNowInSeconds n : Float) {
        let d=UInt64(n*1.0e9)
        let n=DispatchTime.now()
        self.init(uptimeNanoseconds: n.uptimeNanoseconds+d)
    }
    
    init(fromNowForMIDIPacket p: MIDIPacket,withOffsetInSeconds o : Float = 0) {
        let n=DispatchTime.now()
        let o1=UInt64(o*1.0e9)
        let o2=p.timeStamp
        self.init(uptimeNanoseconds: n.uptimeNanoseconds+o1+o2)
    }
    
    func offset(by o: Int) -> DispatchTime {
        return DispatchTime(uptimeNanoseconds: uptimeNanoseconds.advanced(by: o))
    }
    
    func offset(by f: Float) -> DispatchTime {
        return offset(by: Int(f*1.0e9))
    }

    
    var timestamp : MIDITimeStamp { return uptimeNanoseconds }
    
}

func conv(length : Int,_ p : UnsafeMutableRawPointer) -> UnsafeMutableBufferPointer<UInt8> {
    let b = p.bindMemory(to: UInt8.self, capacity: length)
    return UnsafeMutableBufferPointer(start : b,count : length)
}

enum MIDIPacketError : Error {
    case UnknownCommandType
    case MissingParameters
    case CannotDoSysExYet
}

extension MIDIPacket {
    
    public init(_ d : MIDIMessageDescription,timestamp: MIDITimeStamp) throws {
    
        guard let cmd : MIDICommandTypes = d["Command"], let channel : UInt8 = d["Channel"] else { throw MIDIPacketError.UnknownCommandType }
        var bytes : [UInt8] = []
        let command = cmd.raw | (channel & 0x0f)
        switch cmd {
        case .NoteOnEvent, .NoteOffEvent:
            guard let note : MIDINote = d["Note"], let velocity : UInt8 = d["Velocity"] else { throw MIDIPacketError.MissingParameters }
            bytes = [command,note.code,velocity]
        case .KeyPressure:
            guard let note : MIDINote = d["Note"], let pressure : UInt8 = d["Pressure"] else { throw MIDIPacketError.MissingParameters }
            bytes = [command,note.code,pressure]
        case .ControlChange:
            guard let channel : UInt8 = d["Command"], let value : UInt8 = d["Value"] else { throw MIDIPacketError.MissingParameters }
            bytes = [command,channel,value]
        case .ProgramChange:
            guard let prog : UInt8 = d["Program"] else { throw MIDIPacketError.MissingParameters }
            bytes = [command,prog]
        case .ChannelPressure:
            guard let pressure : UInt8 = d["Pressure"] else { throw MIDIPacketError.MissingParameters }
            bytes = [command,pressure]
        case .PitchBend:
            guard let bend : Int16 = d["Bend"] else { throw MIDIPacketError.MissingParameters }
            let b = bend + 2048
            bytes = [command,numericCast(b>>7),numericCast(b&0x7f)]
        default:
            throw MIDIPacketError.CannotDoSysExYet
        }
        self.init(timeStamp: timestamp, bytes: bytes, length: numericCast(bytes.count))
    }
    

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

extension Int {
    
    func toBytes() -> [UInt8] {
        var s=self
        let p=conv(length:MemoryLayout<Int>.size,&s)
        return Array<UInt8>(p.reversed())
    }
    
    static func fromBytes(_ b: [UInt8]) -> Int {
        var s : Int = 0
        let length=MemoryLayout<Int>.size
        let p=conv(length:length,&s)
        b.reversed().prefix(length).enumerated().forEach { p[$0.offset]=$0.element }
        return s
    }
    
    func bound(_ mi: Int,_ ma: Int) -> Int {
        return Swift.min(ma,Swift.max(mi,self))
    }
    func bound(_ r : CountableRange<Int>) -> Int {
        return self.bound(r.lowerBound,r.upperBound-1)
    }
    func bound(_ r : CountableClosedRange<Int>) -> Int {
        return self.bound(r.lowerBound,r.upperBound)
    }
    
    
}

extension UInt32 {
    var bytes : [UInt8] {
        let out=(0..<4).map { UInt8(self>>UInt32(8*$0)) & UInt8(0xff) }
        return out.reversed()
    }
}

extension UInt8 {
    public func hex() -> String { return String(format: "%02x", self) }
    
    init?(number : Int?) {
        if number==nil || number!>255 || number! < -256 { return nil }
        if number!>=0 { self.init(number!) }
        else { self.init(256+number!) }
    }
    
    init(number : Int?,default d: UInt8) {
        var value : Int = Int(d)
        if number != nil && number! < 256 && number! >= -256 {
            if number!>=0 { value=number! }
            else { value=256+number! }
        }
        self.init(value)
    }
}

extension String {
    
    
    
    var range: NSRange {
        return NSRange(location: 0, length: count)
    }
    
    
    
    func camelToSpaced() -> String {
        if count < 1 { return self}
        let regexp=try! NSRegularExpression(pattern: "([A-Z].)")
        let range=NSRange(location: 1, length: count-1)
        return regexp.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: " $1")
    }
    
    class ASCIIView : Collection {
        typealias Index=Int
        
        let bytes : [UInt8]
        
        init?(_ utf : String.UTF8View) {
            let bad=utf.filter { $0>=128 }
            if bad.count > 0 { return nil }
            else {
                bytes=utf.map { $0 }
            }
        }
        
        convenience init?(_ string: String) {
            self.init(string.utf8)
        }
        
        init(_ b : [UInt8]) {
            bytes=b
        }
        
        var startIndex: Int { return 0 }
        var endIndex: Int { return bytes.count }
        
        func index(after i: Int) -> Int {
            return Swift.min(i+1,endIndex)
        }
        
        subscript(_ index : Int) -> UInt8 {
            return bytes[index]
        }
        
        var string : String { return String(bytes: bytes, encoding: .ascii)! }
        
        func padding(toLength l: Int, withPad p: UInt8) -> ASCIIView {
            let b=Array(bytes.prefix(l))
            let pad=Array<UInt8>.init(repeating: p, count: l-b.count)
            return ASCIIView(b+pad)
        }
    }
    
    var ascii : ASCIIView? { return ASCIIView(self) }
}





