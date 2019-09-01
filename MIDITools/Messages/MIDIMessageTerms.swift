//
//  MIDIMessageTerms.swift
//  MIDITools
//
//  Created by Julian Porter on 01/09/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation


public enum MIDITerms : NameableEnumeration, Serialisable, CustomStringConvertible {
    
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
    public var str : String { return name }
    public var description: String { return name }
}

public typealias MIDIDict = OrderedDictionary<MIDITerms,Serialisable>
public typealias Pair = MIDIDict.Element

