//
//  MIDISysExTypes.swift
//  MIDITools
//
//  Created by Julian Porter on 15/05/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public enum MIDISysExTypes : UInt8, MIDIEnumeration {
    
    
    case RealTime = 0x7f
    case NonRealTime = 0x7e
    case UNKNOWN = 0xff
    
    public static let names : [MIDISysExTypes:String] = [
        .RealTime : "Real Time",
        .NonRealTime : "Not Real Time"
    ]
    public static let _unknown : MIDISysExTypes = .UNKNOWN
    
    public static func parse(_ bytes : OffsetArray<UInt8>) -> MIDIDict? {
        guard bytes.count >= 2 else { return nil }
        let command = MIDISysExTypes(bytes[0])
        let out=MIDIDict([KVPair("ID",command),KVPair("DeviceID",bytes[1])])
        
        switch command {
        case .RealTime:
            guard let cmds=MIDISysExRealTimeTypes.parse(bytes.shift(2)) else { return nil }
            out.append(cmds)
        case .NonRealTime:
            guard let cmds=MIDISysExNonRealTimeTypes.parse(bytes.shift(2)) else { return nil }
            out.append(cmds)
        default:
            return MIDIDict(KVPair("Manufacturer",bytes[0]))
        }
        return out
    }
}

public let MIDISysExAllCall : UInt8 = 0x7f

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
    
    public static func parse(_ bytes : OffsetArray<UInt8>) -> MIDIDict? {
        guard bytes.count > 0 else { return nil }
        
        let command=MIDISysExNonRealTimeTypes(bytes[0])
        let out = MIDIDict(KVPair("Sub-ID#1", command))
        switch command {
        case .Timecode, .SampleDumpExtensions, .Information, .FileDump, .Tuning, .General, .DownloadableSounds, .FileReference, .Visual, .Capability:
            guard bytes.count >= 2 else { return nil }
            out["Sub-ID#2"]=bytes[1]
        case .EOF, .Wait, .Cancel, .NAK, .ACK:
            break
        case .SampleDumpHeader, .SampleDumpPacket, .SampleDumpRequest :
            out["Data"]="..."
        default:
            return nil
        }
        return out
    }
}

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
    
    public static func parse(_ bytes : OffsetArray<UInt8>) -> MIDIDict? {
        guard bytes.count > 0 else { return nil }
        
        let command=MIDISysExRealTimeTypes(bytes[0])
        let out = MIDIDict(KVPair("Sub-ID#1", command))
        switch command {
        case .Timecode, .ShowControl, .Information, .Device, .Cueing, .MachineCommands, .MachineResponses, .Tuning, .Destination, .KeyBased, .ScalablePolyphony, .Mobile:
            guard bytes.count >= 2 else { return nil }
            out["Sub-ID#2"]=bytes[1]
        default:
            return nil
        }
        return out
    }
}
