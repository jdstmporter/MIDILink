//
//  sysEx.swift
//  MIDIUtils
//
//  Created by Julian Porter on 02/09/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation

public let MIDISysExAllCall : UInt8 = 0x7f

public enum MIDISysExTypes : UInt8, MIDIEnumeration {
    
    case RealTime = 0x7f
    case NonRealTime = 0x7e
    case UNKNOWN = 0xff
    
    public static let names : [MIDISysExTypes:String] = [
        .RealTime : "Real Time",
        .NonRealTime : "Not Real Time"
    ]
    public static let _unknown : MIDISysExTypes = .UNKNOWN
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws -> MIDIDict {
        guard bytes.count >= 2 else { throw MIDIMessageError(reason: .NoContent) }
        let out = MIDIDict()
        let command = MIDISysExTypes(bytes[0])
        
        switch command {
        case .RealTime:
            let cmds=try MIDISysExRealTimeTypes.parse(bytes.shift(2))
            out[.SysExID] = command
            out[.SysExDeviceID] = bytes[1]
            out.append(cmds)
        case .NonRealTime:
            let cmds=try MIDISysExNonRealTimeTypes.parse(bytes.shift(2))
            out[.SysExID] = command
            out[.SysExDeviceID] = bytes[1]
            out.append(cmds)
        default:
            out[.Manufacturer] = bytes[0]
        }
        return out
    }
}
