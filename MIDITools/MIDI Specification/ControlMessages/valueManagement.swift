//
//  valueManagement.swift
//  MIDIUtils
//
//  Created by Julian Porter on 01/09/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol TransformerProtocol {
    subscript(_ : UInt8) -> String { get }
    subscript(_ : String) -> UInt8 { get }
}

public struct Bool64 : TransformerProtocol {
    public subscript(_ x: UInt8) -> String { x >= 64 ? "ON" : "OFF"  }
    public subscript(_ x: String) -> UInt8 { x == "ON" ? 64 : 0 }

}
public struct Bool127 : TransformerProtocol {
    public subscript(_ x: UInt8) -> String { x == 127 ? "ON" : "OFF"  }
    public subscript(_ x: String) -> UInt8 { x == "ON" ? 127 : 0 }
    
}
public struct BoolTrue : TransformerProtocol {
    public subscript(_ x: UInt8) -> String { "ON"  }
    public subscript(_ x: String) -> UInt8 { 127 }
    
}
public struct BoolFalse : TransformerProtocol {
    public subscript(_ x: UInt8) -> String { "OFF"  }
    public subscript(_ x: String) -> UInt8 {  0 }
    
}
public struct NULL: TransformerProtocol {
    public subscript(_ x: UInt8) -> String { "" }
    public subscript(_ x: String) -> UInt8 { 255 }
    
}

public struct BYTE: TransformerProtocol {
    public subscript(_ x : UInt8) -> String { x.hex() }
    public subscript(_ x : String) -> UInt8 { 0 }
}

public let bool64 = Bool64()
public let bool127 = Bool127()
public let boolTrue = BoolTrue()
public let boolFalse = BoolFalse()
public let null = NULL()
public let byte = BYTE()


public enum MIDIControlMessageTransformation : CaseIterable {
    case OnOff64
    case OnOff127
    case On
    case Off
    case Null
    case Byte
    
    public var transformer : TransformerProtocol {
        switch self {
        case .OnOff64: return bool64
        case .OnOff127: return bool127
        case .On: return boolTrue
        case .Off: return boolFalse
        case .Null: return null
        case .Byte: return byte
        }
    }
    
    public func describe(_ value : UInt8) -> String { self.transformer[value] }
    /*
    public func describe(_ value : UInt8) -> String {
        switch self {
        case .OnOff64: return (value<=63) ? "OFF" : "ON"
        case .OnOff127: return (value==127) ? "OFF" : "ON"
        case .On: return "ON"
        case .Off: return "OFF"
        case .Null: return ""
        case .Byte: return "\(value)"
        }
    }*/
}

