//
//  Enumerations.swift
//  MIDITools
//
//  Created by Julian Porter on 22/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol Nameable {
    var str : String { get }
}


extension UInt32 : Nameable {
    var hex : String {
        return String(format: "%08x",self)
    }
    public var str : String { return hex }
}

extension Int32 : Nameable {
    
    var hex : String {
        return UInt32(truncatingIfNeeded: self).hex
    }
     public var str : String { return hex }
    
}
extension UInt8 : Nameable { public var str : String { hex() } }
extension UInt16: Nameable { public var str : String { "\(self)" }}
extension Int16: Nameable { public var str : String { "\(self)" }}
extension UInt64: Nameable { public var str : String { "\(self)" }}

extension String : Nameable { public var str : String { self } }
extension Bool : Nameable { public var str : String { self ? "ON" : "OFF" } }

public protocol NameableEnumeration : CaseIterable, Hashable, Nameable {
    var name : String { get }
    init?(_ : String)
}

extension NameableEnumeration {
    
    public init?(_ name : String) {
        if let item = (Self.allCases.first { $0.name==name }) { self=item }
        else { return nil }
    }
    public var str : String { name }
}

public protocol StaticNamedEnumeration : NameableEnumeration {
    
    static var names : [Self:String] { get }
}

extension StaticNamedEnumeration {
    
    public var name : String { return Self.names[self] ?? "" }
    
    
}
