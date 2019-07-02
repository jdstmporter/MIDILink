//
//  Extensions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
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

extension UInt8 : Nameable {
    public var str : String { return hex() }
}

extension String : Nameable {
    public var str : String { return self }
}





