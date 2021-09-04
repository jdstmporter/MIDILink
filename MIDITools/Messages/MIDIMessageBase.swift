//
//  MIDIDefinitions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 08/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI




public protocol MIDIEnumeration : RawRepresentable, StaticNamedEnumeration, Comparable where RawValue == UInt8, AllCases == [Self] {
    
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




