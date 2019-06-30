//
//  MIDIDefinitions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 08/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

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


protocol MIDIEnumeration : RawRepresentable, Serialisable, CaseIterable, Hashable, Comparable where RawValue == UInt8, AllCases == [Self] {
    
    static var _unknown : Self { get }
    static var names : [Self:String] { get }
    var raw : UInt8 { get }
    var name : String { get }
    
    
    init(_ : RawValue)
    init?(_ : String)
    static func has(_ : UInt8) -> Bool
    static func parse(_ : OffsetArray<UInt8>) -> [KVPair]?
    
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




