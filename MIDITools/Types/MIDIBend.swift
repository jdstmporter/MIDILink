//
//  MIDIBend.swift
//  MIDITools
//
//  Created by Julian Porter on 01/09/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public struct Bend : Serialisable {
    
    let hi: UInt8
    let lo: UInt8
    let bend : Int16
    
    init(hi: UInt8,lo: UInt8) {
        self.hi = hi
        self.lo = lo
        let v : UInt16 = (numericCast(hi) << 7) | numericCast(lo)
        self.bend  = numericCast(v & 0x3fff) - 2048
    }
    init?(_ b : Int16?) {
        guard let b = b, b >= -2048, b < 2048 else { return nil }
        self.bend = b
        let v : UInt16 = numericCast(b+2048)
        self.hi = numericCast((v>>7)&0x7f)
        self.lo = numericCast(v&0x7f)
    }
    
    public var str: String { return "(\(hi),\(lo)) = \(bend)"}
}
