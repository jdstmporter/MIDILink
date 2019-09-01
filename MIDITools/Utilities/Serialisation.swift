//
//  Serialisation.swift
//  MIDITools
//
//  Created by Julian Porter on 22/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol Serialisable   {
    var str : String { get }
}

extension  UInt8: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt16: Serialisable {
    public var str : String { return "\(self)" }
}
extension  Int16: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt32: Serialisable {
    public var str : String { return "\(self)" }
}
extension  UInt64: Serialisable {
    public var str : String { return "\(self)" }
}
extension String : Serialisable {
    public var str : String { return self }
}
extension Bool : Serialisable {
    public var str : String { return self ? "ON" : "OFF" }
}




