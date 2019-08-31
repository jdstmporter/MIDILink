//
//  Enumerations.swift
//  MIDITools
//
//  Created by Julian Porter on 22/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public protocol NameableEnumeration : CaseIterable, Hashable {
    var name : String { get }
    init?(_ : String)
}

extension NameableEnumeration {
    
    public init?(_ name : String) {
        if let item = (Self.allCases.first { $0.name==name }) { self=item }
        else { return nil }
    }
}

public protocol NamedEnumeration : NameableEnumeration {
    
    static var names : [Self:String] { get }
}

extension NamedEnumeration {
    
    public var name : String { return Self.names[self] ?? "" }
    public var str : String { return self.name }
    
    
}
