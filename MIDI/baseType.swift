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


public class MIDIBase : CustomStringConvertible, Hashable {

    internal var this : MIDIEndpointRef
    public var uid : MIDIUniqueID
    internal var type : MIDIObjectType
    
    public init(_ u : MIDIUniqueID) throws {
        uid=u
        (this,type)=try u.getObject()
    }
    
    public var name : String { return this.getSafe(stringProperty: kMIDIPropertyName)  ?? "" }
    public var model : String { return this.getSafe(stringProperty: kMIDIPropertyModel) ?? "" }
    public var manufacturer : String { return this.getSafe(stringProperty: kMIDIPropertyManufacturer) ?? "" }
    
    public var kind : MIDIObjectKind { return type.kind }
    public var mode : MIDIObjectMode { return type.mode }
    public var disposition : MIDIObjectLocation { return type.location }
    
    public var isSource : Bool { return mode == .source }
    public var isDestination : Bool { return mode == .destination }
    
    
    public var Object : MIDIObjectRef { return this }
    public var UID : String { return String(format:"%08X",uid) }
    public var typeName : String { return "\(kind)" }
    
    public var targetName : String {
            return "\(UID)-\(mode.name)"
    }
    
    public func test(reason: MIDIError.Reason, _ m: MIDIObjectMode) throws {
        if mode != m { throw MIDIError(reason: reason) }
    }
    public var description : String {
        return String(format:"[%08x] %@ %@ %@",uid,name,model,manufacturer)
    }
    
    public static func ==(_ l : MIDIBase, _ r : MIDIBase) -> Bool { return l.uid == r.uid }
    public static func !=(_ l : MIDIBase, _ r : MIDIBase) -> Bool { return l.uid != r.uid }
    public func hash(into hasher: inout Hasher) {
        return uid.hash(into: &hasher)
    }
    public var hashValue : Int { return uid.hashValue }
    
    public var thru : MIDIThruConnectionEndpoint { return MIDIThruConnectionEndpoint(endpointRef: this, uniqueID: uid) }
    
}

