//
//  MIDIBase.swift
//  MIDIUtils
//
//  Created by Julian Porter on 01/09/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation

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

public typealias MIDIDict = OrderedDictionary<MIDITerms,Nameable>
public typealias Pair = MIDIDict.Element

public protocol ParsedMessage : Nameable, Sequence where Iterator==MIDIDict.Iterator {
    associatedtype CommandType : MIDIEnumeration
    
    var body : MIDIDict { get }
    var count : Int { get }
    var length : UInt8 { get }
    var str : String { get }
    var command : CommandType { get }
    
    init(_ bytes : OffsetArray<UInt8>) throws
    
    var interpretedValue : Nameable? { get }
    
}

public extension ParsedMessage  {
    
    var count : Int { self.body.count }
    var length : UInt8 { 0 }
    func makeIterator() -> Iterator { self.body.makeIterator() }
    
    var interpretedValue : Nameable? { self.body[.InterpretedValue] }
    var str : String {
         if let interpreted = interpretedValue { return "\(command) = \(interpreted)" }
         else { return "\(self.command)" }
    }
    
    
}
