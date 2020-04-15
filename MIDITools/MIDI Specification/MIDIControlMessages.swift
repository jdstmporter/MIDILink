//
//  MIDIControlMessages.swift
//  MIDIUtils
//
//  Created by Julian Porter on 18/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation



public protocol MIDISerialiser {
    
    init(messages: [MIDIMessage])
    
    var data : Data { get }
    var str : String { get }
}


public protocol TransformerProtocol {
    subscript(_ : UInt8) -> String? { get }
    subscript(_ : String?) -> UInt8 { get }
}

public struct Bool64 : TransformerProtocol {
    public subscript(_ x: UInt8) -> String? { x >= 64 ? "ON" : "OFF"  }
    public subscript(_ x: String?) -> UInt8 { x == "ON" ? 64 : 0 }

}
public struct Bool127 : TransformerProtocol {
    public subscript(_ x: UInt8) -> String? { x == 127 ? "ON" : "OFF"  }
    public subscript(_ x: String?) -> UInt8 { x == "ON" ? 127 : 0 }
    
}
public struct BoolTrue : TransformerProtocol {
    public subscript(_ x: UInt8) -> String? { "ON"  }
    public subscript(_ x: String?) -> UInt8 { 127 }
    
}
public struct BoolFalse : TransformerProtocol {
    public subscript(_ x: UInt8) -> String? { "OFF"  }
    public subscript(_ x: String?) -> UInt8 {  0 }
    
}
public struct NULL: TransformerProtocol {
    public subscript(_ x: UInt8) -> String? { nil  }
    public subscript(_ x: String?) -> UInt8 { 255 }
    
}



public let bool64 = Bool64()
public let bool127 = Bool127()
public let boolTrue = BoolTrue()
public let boolFalse = BoolFalse()
public let null = NULL()

public enum MIDIControlMessageTransformation : CaseIterable {
    case OnOff64
    case OnOff127
    case On
    case Off
    case Null
    case Byte
    
    public var transformer : TransformerProtocol? {
        switch self {
        case .OnOff64: return bool64
        case .OnOff127: return bool127
        case .On: return boolTrue
        case .Off: return boolFalse
        case .Null: return null
        default: return nil
        }
    }
    
    public func describe(_ value : UInt8) -> String {
        switch self {
        case .OnOff64: return (value<=63) ? "OFF" : "ON"
        case .OnOff127: return (value==127) ? "OFF" : "ON"
        case .On: return "ON"
        case .Off: return "OFF"
        case .Null: return ""
        case .Byte: return "\(value)"
        }
    }
}



public enum MIDIControlMessages : UInt8, MIDIEnumeration {
    
    public static func parse(_ : OffsetArray<UInt8>) throws -> MIDIDict {
        throw MIDIMessageError.BadPacket
    }
    
    case BankSelectMSB = 0x00
    case ModulationWheelMSB = 0x01
    case BreathControllerMSB = 0x02
    case FootControllerMSB = 0x04
    case DataMSB = 0x05
    case PanMSB = 0x06
    case ChannelVolumeMSB = 0x07
    case BalanceMSB = 0x08
    case ExpressionMSB = 0x0b
    case Effects1MSB = 0x0c
    case Effects2MSB = 0x0d
    case GeneralPurpose1MSB = 0x10
    case GeneralPurpose2MSB = 0x11
    case GeneralPurpose3MSB = 0x12
    case GeneralPurpose4MSB = 0x13
    case BankSelectLSB = 0x20
    case ModulationWheelLSB = 0x21
    case BreathControllerLSB = 0x22
    case FootControllerLSB = 0x24
    case DataLSB = 0x25
    case PanLSB = 0x26
    case ChannelVolumeLSB = 0x27
    case BalanceLSB = 0x28
    case ExpressionLSB = 0x2b
    case Effects1LSB = 0x2c
    case Effects2LSB = 0x2d
    case GeneralPurpose1LSB = 0x30
    case GeneralPurpose2LSB = 0x31
    case GeneralPurpose3LSB = 0x32
    case GeneralPurpose4LSB = 0x33
    case Sustain = 0x40
    case PortamentoSwitch = 0x41
    case Sostenuto = 0x42
    case SoftPedal = 0x43
    case LegatoFootSwitch = 0x44
    case Hold2 = 0x45
    case Sound1 = 0x46
    case Sound2 = 0x47
    case Sound3 = 0x48
    case Sound4 = 0x49
    case Sound5 = 0x4a
    case Sound6 = 0x4b
    case Sound7 = 0x4c
    case Sound8 = 0x4d
    case Sound9 = 0x4e
    case Sound10 = 0x4f
    case GeneralPurpose5 = 0x50
    case GeneralPurpose6 = 0x51
    case GeneralPurpose7 = 0x52
    case GeneralPurpose8 = 0x53
    case Portamento = 0x54
    case HighResolutionVelocityPrefix = 0x58
    case Effects1Depth = 0x5b
    case Effects2Depth = 0x5c
    case Effects3Depth = 0x5d
    case Effects4Depth = 0x5e
    case Effects5Depth = 0x5f
    case DataIncrement = 0x60
    case DataDecrement = 0x61
    case NonRegisteredParameterNumberLSB = 0x62
    case NonRegisteredParameterNumberMSB = 0x63
    case RegisteredParameterNumberLSB = 0x64
    case RegisteredParameterNumberMSB = 0x65
    case AllSoundOff = 0x78
    case ResetAllControllers = 0x79
    case LocalControl = 0x7a
    case AllNotesOff = 0x7b
    case OmniModeOff = 0x7c
    case OmniModeOn = 0x7d
    case MonoMode = 0x7e
    case PolyModeOn = 0x7f
    
    case UNKNOWN = 0xff
    
     static let names : [MIDIControlMessages : String] = [
        .BankSelectMSB : "Bank select MSB",
        .ModulationWheelMSB : "Modulation wheel MSB",
        .BreathControllerMSB : "Breath controller MSB",
        .FootControllerMSB : "Foot Controller MSB",
        .DataMSB : "Data MSB",
        .PanMSB : "Pan MSB",
        .ChannelVolumeMSB : "Channel volume MSB",
        .BalanceMSB : "Balance MSB",
        .ExpressionMSB : "Expression MSB",
        .Effects1MSB : "Effects 1 MSB",
        .Effects2MSB : "Effects 2 MSB",
        .GeneralPurpose1MSB : "General purpose 1 MSB",
        .GeneralPurpose2MSB : "General purpose 2 MSB",
        .GeneralPurpose3MSB : "General purpose 3 MSB",
        .GeneralPurpose4MSB : "General purpose 4 MSB",
        .BankSelectLSB : "Bank select LSB",
        .ModulationWheelLSB : "Modulation wheel LSB",
        .BreathControllerLSB : "Breath controller LSB",
        .FootControllerLSB : "Foot Controller LSB",
        .DataLSB : "Data LSB",
        .PanLSB : "Pan LSB",
        .ChannelVolumeLSB : "Channel volume LSB",
        .BalanceLSB : "Balance LSB",
        .ExpressionLSB : "Expression LSB",
        .Effects1LSB : "Effects 1 LSB",
        .Effects2LSB : "Effects 2 LSB",
        .GeneralPurpose1LSB : "General purpose 1 LSB",
        .GeneralPurpose2LSB : "General purpose 2 LSB",
        .GeneralPurpose3LSB : "General purpose 3 LSB",
        .GeneralPurpose4LSB : "General purpose 4 LSB",
        .Sustain : "Sustain",
        .PortamentoSwitch : "Portamento switch",
        .Sostenuto : "Sostenuto",
        .SoftPedal : "Soft pedal",
        .LegatoFootSwitch : "Legato foot switch",
        .Hold2 : "Hold2",
        .Sound1 : "Sound 1",
        .Sound2 : "Sound 2",
        .Sound3 : "Sound 3",
        .Sound4 : "Sound 4",
        .Sound5 : "Sound 5",
        .Sound6 : "Sound 6",
        .Sound7 : "Sound 7",
        .Sound8 : "Sound 8",
        .Sound9 : "Sound 9",
        .Sound10 : "Sound 10",
        .GeneralPurpose5 : "General purpose 5",
        .GeneralPurpose6 : "General purpose 6",
        .GeneralPurpose7 : "General purpose 7",
        .GeneralPurpose8 : "General purpose 8",
        .Portamento : "Portamento",
        .HighResolutionVelocityPrefix : "High resolution velocity prefix",
        .Effects1Depth : "Effects 1 depth",
        .Effects2Depth : "Effects 2 depth",
        .Effects3Depth : "Effects 3 depth",
        .Effects4Depth : "Effects 4 depth",
        .Effects5Depth : "Effects 5 depth",
        .DataIncrement : "Data increment",
        .DataDecrement : "Data decrement",
        .NonRegisteredParameterNumberLSB : "Non-registered parameter number LSB",
        .NonRegisteredParameterNumberMSB : "Non-registered parameter number MSB",
        .RegisteredParameterNumberLSB : "Registered parameter number LSB",
        .RegisteredParameterNumberMSB : "Registered parameter number MSB",
        .AllSoundOff : "All sound",
        .ResetAllControllers : "Reset all controllers",
        .LocalControl : "Local control",
        .AllNotesOff : "All notes",
        .OmniModeOff : "Omni mode",
        .OmniModeOn : "Omni mode",
        .MonoMode : "Mono mode",
        .PolyModeOn : "Poly mode"
    ]
    
     public static let _unknown : MIDIControlMessages = .UNKNOWN
    
    internal static let transform : [MIDIControlMessages : MIDIControlMessageTransformation] = [
        .Sustain : .OnOff64,
        .PortamentoSwitch : .OnOff64,
        .Sostenuto : .OnOff64,
        .SoftPedal : .OnOff64,
        .LegatoFootSwitch : .OnOff64,
        .AllSoundOff : .Off,
        .LocalControl : .OnOff127,
        .AllNotesOff : .Off,
        .OmniModeOff : .Off,
        .OmniModeOn : .On,
        .PolyModeOn : .On,
        .DataIncrement : .Null,
        .DataDecrement : .Null
    ]
    
    internal static let transformers : [MIDIControlMessages : TransformerProtocol] = [
        .Sustain : bool64,
        .PortamentoSwitch : bool64,
        .Sostenuto : bool64,
        .SoftPedal : bool64,
        .LegatoFootSwitch : bool64,
        .AllSoundOff : boolFalse,
        .LocalControl : bool127,
        .AllNotesOff : boolFalse,
        .OmniModeOff : boolFalse,
        .OmniModeOn : boolTrue,
        .PolyModeOn : boolTrue,
        .DataIncrement : null,
        .DataDecrement : null
    ]
    
    public var transformer : TransformerProtocol? {
        return MIDIControlMessages.transformers[self]
    }
    
    public var transform : MIDIControlMessageTransformation {
        return MIDIControlMessages.transform[self] ?? .Byte
    }
    
    public var needsValue : Bool { transform != .Null }
    
    
}

/*

public class Thresholder {
    let on : UInt8
    let off : UInt8
    let threshold : (UInt8) -> Bool
    
    public init(function t : @escaping (UInt8) -> Bool,on _on:UInt8, off _off :UInt8) {
        threshold=t
        on=_on
        off=_off
    }
    
    public subscript(_ x : UInt8) -> Bool {
        return threshold(x)
    }
}


public class MIDIController {
    
    public static let ControlCodes : [UInt8:(String,MIDIMessageValueType)] = [
        0x00:("Bank select MSB",.Byte),
        0x01:("Modulation wheel MSB",.Byte),
        0x02:("Breath controller MSB",.Byte),
        0x04:("Foot controller MSB",.Byte),
        0x05:("Data MSB",.Byte),
        0x06:("Pan MSB",.Byte),
        0x07:("Channel volume MSB",.Byte),
        0x08:("Balance MSB",.Byte),
        0x0a:("Pan MSB",.Byte),
        0x0b:("Expression controller MSB",.Byte),
        0x0c:("Effect control 1 MSB",.Byte),
        0x0d:("Effect control 2 MSB",.Byte),
        0x10:("General purpose controller 1 MSB",.Byte),
        0x11:("General purpose controller 2 MSB",.Byte),
        0x12:("General purpose controller 3 MSB",.Byte),
        0x13:("General purpose controller 4 MSB",.Byte),
        0x20:("Bank select LSB",.Byte),
        0x21:("Modulation wheel LSB",.Byte),
        0x22:("Breath controller LSB",.Byte),
        0x24:("Foot controller LSB",.Byte),
        0x25:("Data LSB",.Byte),
        0x26:("Pan LSB",.Byte),
        0x27:("Channel volume LSB",.Byte),
        0x28:("Balance LSB",.Byte),
        0x2a:("Pan LSB",.Byte),
        0x2b:("Expression controller LSB",.Byte),
        0x2c:("Effect control 1 LSB",.Byte),
        0x2d:("Effect control 2 LSB",.Byte),
        0x30:("General purpose controller 1 LSB",.Byte),
        0x31:("General purpose controller 2 LSB",.Byte),
        0x32:("General purpose controller 3 LSB",.Byte),
        0x33:("General purpose controller 4 LSB",.Byte),
        0x40:("Sustain",.OnOff64),
        0x41:("Portamento",.OnOff64),
        0x42:("Sostenuto",.OnOff64),
        0x43:("Soft pedal",.OnOff64),
        0x44:("Legato footswitch",.Legato),
        0x45:("Hold 2",.OnOff64),
        0x46:("Sound controller 1",.Byte),
        0x47:("Sound controller 2",.Byte),
        0x48:("Sound controller 3",.Byte),
        0x49:("Sound controller 4",.Byte),
        0x4a:("Sound controller 5",.Byte),
        0x4b:("Sound controller 6",.Byte),
        0x4c:("Sound controller 7",.Byte),
        0x4d:("Sound controller 8",.Byte),
        0x4e:("Sound controller 9",.Byte),
        0x4f:("Sound controller 10",.Byte),
        0x50:("General purpose controller 5",.Byte),
        0x51:("General purpose controller 6",.Byte),
        0x52:("General purpose controller 7",.Byte),
        0x53:("General purpose controller 8",.Byte),
        0x54:("Portamento control",.Byte),
        0x58:("High resolution velocity prefix",.Byte),
        0x5b:("Effects 1 depth",.Byte),
        0x5c:("Effects 2 depth",.Byte),
        0x5d:("Effects 3 depth",.Byte),
        0x5e:("Effects 4 depth",.Byte),
        0x5f:("Effects 5 depth",.Byte),
        0x60:("Data increment",.Null),
        0x61:("Data decrement",.Null),
        0x62:("Non-registered parameter number LSB",.Byte),
        0x63:("Non-registered parameter number MSB",.Byte),
        0x64:("Registered parameter number LSB",.Byte),
        0x65:("Registered parameter number MSB",.Byte),
        0x78:("All sound",.OFF),
        0x79:("Reset all controllers",.Null),
        0x7a:("Local control",.OnOff127),
        0x7b:("All notes",.OFF),
        0x7c:("Omni mode",.OFF),
        0x7d:("Omni mode",.ON),
        0x7e:("Mono mode",.Byte),
        0x7f:("Poly mode",.ON),
        0xff:("Other",.Null)
    ]
    
    
    private static let controllers : [(UInt8,String)] = [(1, "Modulation Wheel"), (2 , "Breath controller"), ( 64 , "Sustain"), ( 65 , "Portamento"), ( 66 , "Sostenuto"), ( 67 , "Soft Pedal"), ( 120, "All sound off"), ( 121, "Reset all controllers"), ( 122, "Local"), ( 123, "All notes off"), ( 124, "Omni mode off"), ( 125, "Omni mode on"), ( 126 , "Mono mode"), ( 127 , "Poly mode on"), ( 255 , "Other") ]
    
   
    
    
    public class func code(forIndex index: Int) -> UInt8? {
        if index<0 || index >= MIDIController.controllers.count { return nil }
        return MIDIController.controllers[index].0
    }
    
    public class func name(forIndex index: Int) -> String? {
        if index<0 || index >= MIDIController.controllers.count { return nil }
        return MIDIController.controllers[index].1
    }
    
    public class func count() -> Int { return MIDIController.controllers.count }
    
    public class func isValid(value: UInt8) -> Bool {
        return MIDIController.controllers.filter { $0.0 == value }.count>0
    }
    
    public class func name(forCode code: UInt8) -> String? {
        return MIDIController.controllers.filter { $0.0 == code } .first?.1
    }
    
    public class func value(forCode code: UInt8) -> Bool? {
        let type=MIDIController.ControlCodes[code]?.1
        return (type == .ON) ? true : (type == .OFF) ? false : nil
    }
    
    public class func isBoolean(code: UInt8) -> Bool {
        let type=MIDIController.type(forCode: code)
        return type == .OnOff64 || type == .OnOff127 || type == .Legato
    }
    
    public class func hasValue(code: UInt8) -> Bool {
        return MIDIController.isBoolean(code: code) || MIDIController.type(forCode: code) == .Byte
    }
    
    
    public class func code(forName name: String) -> UInt8? {
        return MIDIController.controllers.filter { $0.1 == name } .first?.0
    }
    
    public class func type(forCode code:UInt8) -> MIDIMessageValueType {
        return MIDIController.ControlCodes[code]?.1 ?? .Null
    }
    
    public class func thresholder(forCode code: UInt8) -> Thresholder? {
        switch MIDIController.type(forCode: code) {
        case .OnOff64, .Legato:
            return Thresholder(function: { $0>=64 }, on: 64, off: 0)
        case .OnOff127:
            return Thresholder(function: { $0 == 127 }, on: 127, off: 0)
        default:
            return nil
        }
    }
    
    public class func OnOffValues(forCode code: UInt8) -> (on:UInt8,off:UInt8)? {
        switch MIDIController.type(forCode: code) {
        case .OnOff64, .Legato:
            return (on:64,off:0)
        case .OnOff127:
            return (on:127,off:0)
        default:
            return nil
        }
    }
    
    public static var all : BiDictionary<UInt8,String> {
        var out=[UInt8:String]()
        MIDIController.ControlCodes.forEach { out[$0.key]=$0.value.0 }
        return BiDictionary<UInt8,String>(out)
    }
    
}
*/

