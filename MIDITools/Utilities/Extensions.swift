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
    
    init() { self.init(uptimeNanoseconds: 0) }
    init(from p : MIDIPacket) { self.init(uptimeNanoseconds: p.timeStamp) }
    
    public init(fromNowInSeconds n : Float) {
        let d=UInt64(n*1.0e9)
        let n=DispatchTime.now()
        self.init(uptimeNanoseconds: n.uptimeNanoseconds+d)
    }
    var timestamp : MIDITimeStamp { uptimeNanoseconds }
}

func conv(length : Int,_ p : UnsafeMutableRawPointer) -> UnsafeMutableBufferPointer<UInt8> {
    let b = p.bindMemory(to: UInt8.self, capacity: length)
    return UnsafeMutableBufferPointer(start : b,count : length)
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
    
    var bytes : OffsetArray<UInt8> { OffsetArray(dataArray) }
    var dataPointer : UnsafeMutablePointer<UInt8>? {
        var d=self.data
        return conv(length:Int(self.length),&d).baseAddress
    }

}

extension Int {
    static func fromBytes(_ b: [UInt8]) -> Int {
        var s : Int = 0
        let length=MemoryLayout<Int>.size
        let p=conv(length:length,&s)
        b.reversed().prefix(length).enumerated().forEach { p[$0.offset]=$0.element }
        return s
    }
    
    func bound(_ mi: Int,_ ma: Int) -> Int { Swift.min(ma,Swift.max(mi,self)) }
    func bound(_ r : CountableRange<Int>) -> Int { self.bound(r.lowerBound,r.upperBound-1) }
    func bound(_ r : CountableClosedRange<Int>) -> Int { self.bound(r.lowerBound,r.upperBound) }
    
    
}


extension UInt8 {
    public func hex() -> String { String(format: "%02x", self) }
    
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
  
    var range: NSRange { NSRange(location: 0, length: count) }
   
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
            else { bytes=utf.map { $0 } }
        }
        
        convenience init?(_ string: String) { self.init(string.utf8)}
        init(_ b : [UInt8]) { bytes=b }
        
        var startIndex: Int { 0 }
        var endIndex: Int { bytes.count }
        func index(after i: Int) -> Int { Swift.min(i+1,endIndex) }
        subscript(_ index : Int) -> UInt8 { bytes[index] }
        
        var string : String { String(bytes: bytes, encoding: .ascii)! }
        
        func padding(toLength l: Int, withPad p: UInt8) -> ASCIIView {
            let b=Array(bytes.prefix(l))
            let pad=Array<UInt8>.init(repeating: p, count: l-b.count)
            return ASCIIView(b+pad)
        }
    }
    
    var ascii : ASCIIView? { ASCIIView(self) }
}





