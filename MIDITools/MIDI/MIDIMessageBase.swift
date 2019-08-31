//
//  MIDIDefinitions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 08/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


public enum MIDITerms : NameableEnumeration, Serialisable, CustomStringConvertible {
    
    case Command
    case Channel
    case Note
    case Velocity
    case Pressure
    case Control
    case Value
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
    public var str : String { return name }
    public var description: String { return name }
    
    
}

public struct Bend : Serialisable {
    
    let hi: UInt8
    let lo: UInt8
    let bend : Int16
    
    init(hi: UInt8,lo: UInt8) {
        self.hi = hi
        self.lo = lo
        let v : UInt16 = (numericCast(hi) << 7) | numericCast(lo)
        self.bend  = numericCast(v & 0x3fff) - 2048
    }
    init?(_ b : Int16?) {
        guard let b = b, b >= -2048, b < 2048 else { return nil }
        self.bend = b
        let v : UInt16 = numericCast(b+2048)
        self.hi = numericCast((v>>7)&0x7f)
        self.lo = numericCast(v&0x7f)
    }
    
    public var str: String { return "(\(hi),\(lo)) = \(bend)"}
}



public typealias MIDIDict = OrderedDictionary<MIDITerms,Serialisable>
public typealias Pair = MIDIDict.Element


protocol MIDIEnumeration : RawRepresentable, Serialisable, CaseIterable, Hashable, Comparable where RawValue == UInt8, AllCases == [Self] {
    
    static var _unknown : Self { get }
    static var names : [Self:String] { get }
    var raw : UInt8 { get }
    var name : String { get }
    
    
    init(_ : RawValue)
    init?(_ : String)
    static func has(_ : UInt8) -> Bool
    static func parse(_ : OffsetArray<UInt8>) -> MIDIDict?
    
}

extension MIDIEnumeration {
    public var raw : UInt8 { return self.rawValue }
    public var name : String { return Self.names[self] ?? "" }
    public var str : String { return self.name }
    
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




