//
//  MIDISysExTypes.swift
//  MIDITools
//
//  Created by Julian Porter on 15/05/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation




public enum MIDISysExNonRealTimeTypes : UInt8, MIDIEnumeration {
    case SampleDumpHeader = 0x01
    case SampleDumpPacket = 0x02
    case SampleDumpRequest = 0x03
    case Timecode = 0x04
    case SampleDumpExtensions = 0x05
    case Information = 0x06
    case FileDump = 0x07
    case Tuning = 0x08
    case General = 0x09
    case DownloadableSounds = 0x0a
    case FileReference = 0x0b
    case Visual = 0x0c
    case Capability = 0x0d
    
    case EOF = 0x7b
    case Wait = 0x7c
    case Cancel = 0x7d
    case NAK = 0x7e
    case ACK = 0x7f
    
    case UNKNOWN = 0xff
    
    public static let names : [MIDISysExNonRealTimeTypes:String] = [
        .SampleDumpHeader : "Sample Dump Header",
        .SampleDumpPacket : "Sample Dump Packet",
        .SampleDumpRequest : "Sample Dump Request",
        .Timecode : "MIDI Time Code",
        .SampleDumpExtensions : "Sample Dump Extensions",
        .Information : "General Information",
        .FileDump : "File Dump",
        .Tuning : "MIDI Tuning Standard",
        .General : "General MIDI",
        .DownloadableSounds : "Downloadable Sounds",
        .FileReference : "File Reference Message",
        .Visual : "MIDI Visual Control",
        .Capability : "MIDI Capability Enquiry",
        .EOF : "End Of File",
        .Wait : "Wait",
        .Cancel : "Cancel",
        .NAK : "NAK",
        .ACK : "ACK"
    ]
    
    public static let _unknown : MIDISysExNonRealTimeTypes = .UNKNOWN
    
    public static func parse(_ bytes : OffsetArray<UInt8>) throws -> MIDIDict {
        guard bytes.count > 0 else { throw MIDIMessageError(reason: .NoContent) }
        
        let command=MIDISysExNonRealTimeTypes(bytes[0])
        let out = MIDIDict()
        out[.SysExSubID1] = command
        switch command {
        case .Timecode, .SampleDumpExtensions, .Information, .FileDump, .Tuning, .General, .DownloadableSounds, .FileReference, .Visual, .Capability:
            guard bytes.count >= 2 else { throw MIDIMessageError(reason: .NoContent) }
            out[.SysExSubID2]=bytes[1]
        case .EOF, .Wait, .Cancel, .NAK, .ACK:
            break
        case .SampleDumpHeader, .SampleDumpPacket, .SampleDumpRequest :
            out[.SysExData]="..."
        default:
            return MIDIDict()
        }
        return out
    }
}

