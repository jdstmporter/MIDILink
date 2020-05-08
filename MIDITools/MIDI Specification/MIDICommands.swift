//
//  MIDIMessageTypes.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


public enum MIDICommands : UInt8, MIDIEnumeration {
    
    case NoteOffEvent    = 0x80
    case NoteOnEvent     = 0x90
    case KeyPressure     = 0xa0
    case ControlChange   = 0xb0
    case ProgramChange   = 0xc0
    case ChannelPressure = 0xd0
    case PitchBend       = 0xe0
    case SystemMessage   = 0xf0
    case UNKNOWN         = 0
    
    public  static let names : [MIDICommands:String] = [
        .NoteOffEvent    : "Note Off",
        .NoteOnEvent     : "Note On",
        .KeyPressure     : "Key Pressure",
        .ControlChange   : "Control Change",
        .ProgramChange   : "Program Change",
        .ChannelPressure : "Channel Pressure",
        .PitchBend       : "Pitch Bend",
        .SystemMessage   : "System"
    ]
    

    public static let _unknown : MIDICommands = .UNKNOWN
    public init(_ cmd: UInt8) {
        self = MIDICommands.init(rawValue: cmd & 0xf0) ?? MIDICommands._unknown
    }
    
    public static func parse(_ b: OffsetArray<UInt8>) throws -> MIDIDict { try MIDIMessageParser(b).dict
    }
    
    
}

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



