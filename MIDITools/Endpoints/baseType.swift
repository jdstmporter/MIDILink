//
//  baseType.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public enum MIDIObjectKind : Int32 {
    case device = 0
    case entity = 1
    case source = 2
    case dest   = 3
    case other  = -1
}
public enum MIDIObjectMode {
    case source
    case destination
    case other
    
    public var name : String {
        switch self {
        case .source:
            return "IN"
        case .destination:
            return "OUT"
        default:
            return "NA"
        }
    }
}
public enum MIDIObjectLocation {
    case int
    case ext
    case other
}


