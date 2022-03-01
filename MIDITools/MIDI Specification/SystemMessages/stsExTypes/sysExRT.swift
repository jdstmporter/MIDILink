//
//  sysExRT.swift
//  MIDIUtils
//
//  Created by Julian Porter on 02/09/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation

public enum MIDISysExRealTimeTypes : UInt8, MIDIEnumeration {
    
    case Timecode = 0x01
    case ShowControl = 0x02
    case Information = 0x03
    case Device = 0x04
    case Cueing = 0x05
    case MachineCommands = 0x06
    case MachineResponses = 0x07
    case Tuning = 0x08
    case Destination = 0x09
    case KeyBased = 0x0a
    case ScalablePolyphony = 0x0b
    case Mobile = 0x0c
    
    case UNKNOWN = 0xff
    
    public static let names : [MIDISysExRealTimeTypes:String] = [
        .Timecode : "MIDI Time Code",
        .ShowControl : "MIDI Show Control",
        .Information : "Notation Information",
        .Device : "Device Control",
        .Cueing : "MTC Cueing",
        .MachineCommands : "MIDI Machine Control Commands",
        .MachineResponses : "MIDI Machine Control Responses",
        .Tuning : "MIDI Tuning Standard",
        .Destination : "Controller Destination Setting",
        .KeyBased : "Key-based Instrument Control",
        .ScalablePolyphony : "Scalable Polyphony MIDI MIP Message",
        .Mobile : "Mobile Phone Control Message"
    ]
    
    public static let _unknown : MIDISysExRealTimeTypes = .UNKNOWN
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws  -> MIDIDict {
        guard bytes.count > 0 else { throw MIDIMessageError(reason: .NoContent) }
        
        let command=MIDISysExRealTimeTypes(bytes[0])
        let out = MIDIDict()
        out[.SysExSubID1] = command
        switch command {
        case .Timecode, .ShowControl, .Information, .Device, .Cueing, .MachineCommands, .MachineResponses, .Tuning, .Destination, .KeyBased, .ScalablePolyphony, .Mobile:
            guard bytes.count >= 2 else { throw MIDIMessageError(reason: .NoContent) }
            out[.SysExSubID2]=bytes[1]
        default:
            return MIDIDict()
        }
        return out
    }
}
