//
//  MIDIEnums.swift
//  MIDIManager
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public enum MIDICommandTypes : UInt8 {
    case NoteOffEvent    = 0x80
    case NoteOnEvent     = 0x90
    case KeyPressure     = 0xa0
    case ControlChange   = 0xb0
    case ProgramChange   = 0xc0
    case ChannelPressure = 0xd0
    case PitchBend       = 0xe0
    case SystemMessage   = 0xf0
    case UNKNOWN         = 0
    
    internal static let names : [MIDICommandTypes:String] = [
        .NoteOffEvent    : "Note Off",
        .NoteOnEvent     : "Note On",
        .KeyPressure     : "Key Pressure",
        .ControlChange   : "Control Change",
        .ProgramChange   : "Program Change",
        .ChannelPressure : "Channel Pressure",
        .PitchBend       : "Pitch Bend",
        .SystemMessage   : "System"
    ]
    
    public init(_ cmd : UInt8) {
        self = MIDICommandTypes(rawValue: cmd&0xf0) ?? .UNKNOWN
    }
    public var name : String { return MIDICommandTypes.names[self] ?? "" }
}

public struct KVPair : Encodable {
    public enum CodingKeys : String, CodingKey {
        case key
        case value
    }
    public let key : String
    public let value : Serialisable
    
    public init(_ key : String, _ value : Serialisable) {
        self.key=key
        self.value=value
    }
    
    public func encode(to encoder : Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(value.str, forKey: .value)
    }
    
    
}

public enum MIDIControlMessages : UInt8 {
    
    case ModulationWheel = 1
    case BreathController = 2
    case Sustain = 64
    case Portamento = 65
    case Sostenuto = 66
    case SoftPedal = 67
    case AllSoundOff = 120
    case ResetAllControllers = 121
    case LocalControl = 122
    case AllNotesOff = 123
    case OmniModeOff = 124
    case OmniModeOn = 125
    case MonoMode = 126
    case PolyModeOn = 127
    
    case UNKNOWN = 255
    
    internal static let names : [MIDIControlMessages : String] = [
        .ModulationWheel : "Modulation wheel",
        .BreathController : "Breath controller",
        .Sustain : "Sustain",
        .Portamento : "Portamento",
        .Sostenuto : "Sostenuto",
        .SoftPedal : "Soft pedal",
        .AllSoundOff : "All sound",
        .ResetAllControllers : "Reset all controllers",
        .LocalControl : "Local control",
        .AllNotesOff : "All notes",
        .OmniModeOff : "Omni mode",
        .OmniModeOn : "Omni mode",
        .MonoMode : "Mono mode",
        .PolyModeOn : "Poly mode"
    ]
    
    internal typealias Argument = (UInt8) -> Serialisable
    
    internal static let byteArg : Argument = { $0 }
    internal static let bool64 : Argument = { $0 >= 64 }
    internal static let bool127 : Argument = { $0 == 127 }
    internal static let boolTrue : Argument = {_ in true }
    internal static let boolFalse : Argument = {_ in false }
    
    internal static let transformers : [MIDIControlMessages : Argument] = [
        .ModulationWheel : byteArg,
        .BreathController : byteArg,
        .Sustain : bool64,
        .Portamento : bool64,
        .Sostenuto : bool64,
        .SoftPedal : bool64,
        .AllSoundOff : boolFalse,
        .ResetAllControllers : byteArg,
        .LocalControl : bool127,
        .AllNotesOff : boolFalse,
        .OmniModeOff : boolFalse,
        .OmniModeOn : boolTrue,
        .MonoMode : byteArg,
        .PolyModeOn : boolTrue
    ]
    
    public init(_ cmd : UInt8) {
        self=MIDIControlMessages(rawValue: cmd) ?? .UNKNOWN
    }
    public var name : String { return MIDIControlMessages.names[self] ?? "" }
    public func kv(_ arg: UInt8) -> KVPair? {
        if let n = MIDIControlMessages.names[self] {
            if let trans = MIDIControlMessages.transformers[self] {
                return KVPair( n,trans(arg))
            }
            else { return KVPair(n,arg) }
        }
        else { return nil }
    }
}
