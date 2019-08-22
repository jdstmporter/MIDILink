//
//  Enumerations.swift
//  MIDITools
//
//  Created by Julian Porter on 22/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol NamedEnumeration : CaseIterable, Hashable {
    
    static var names : [Self:String] { get }
    var name : String { get }
    init?(_ : String)
}

extension NamedEnumeration {
    
    public var name : String { return Self.names[self] ?? "" }
    public var str : String { return self.name }
    
    public init?(_ name : String) {
        if let kv = (Self.names.first { $0.value==name }) { self=kv.key }
        else { return nil }
    }
}
