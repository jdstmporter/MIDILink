//
//  MIDIMessageTypes.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public enum MIDICommandTypes : UInt8, MIDIEnumeration {
    
    
    case NoteOffEvent    = 0x80
    case NoteOnEvent     = 0x90
    case KeyPressure     = 0xa0
    case ControlChange   = 0xb0
    case ProgramChange   = 0xc0
    case ChannelPressure = 0xd0
    case PitchBend       = 0xe0
    case SystemMessage   = 0xf0
    case UNKNOWN         = 0
    
     static let names : [MIDICommandTypes:String] = [
        .NoteOffEvent    : "Note Off",
        .NoteOnEvent     : "Note On",
        .KeyPressure     : "Key Pressure",
        .ControlChange   : "Control Change",
        .ProgramChange   : "Program Change",
        .ChannelPressure : "Channel Pressure",
        .PitchBend       : "Pitch Bend",
        .SystemMessage   : "System"
    ]
    

    public static let _unknown : MIDICommandTypes = .UNKNOWN
    public init(_ cmd: UInt8) {
        self = MIDICommandTypes.init(rawValue: cmd & 0xf0) ?? MIDICommandTypes._unknown
    }
    
    public static func parse(_ b: OffsetArray<UInt8>) throws -> MIDIMessageDescription {
        return try MIDIMessageDescription(b)
    }
    
    
}

