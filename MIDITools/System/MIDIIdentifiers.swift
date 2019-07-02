//
//  MIDIIdentifiers.swift
//  MIDIToolkit
//
//  Created by Julian Porter on 24/04/2018.
//  Copyright © 2018 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI

extension MIDIObjectRef {
    public func getSafe(stringProperty key: CFString) -> String? {
        var out : Unmanaged<CFString>?
        let error=MIDIObjectGetStringProperty(self, key, &out)
        if error != noErr { return nil }
        return ((out?.takeUnretainedValue()) as String?)
    }
    
    public func getSafe(integerProperty key: CFString) -> Int32? {
        var out : Int32=0
        let error=MIDIObjectGetIntegerProperty(self, key, &out)
        if error != noErr { return nil }
        return out
    }
    
    public func get(stringProperty key: CFString) throws -> String {
        guard let out=getSafe(stringProperty: key) else { throw MIDIError(reason:.CannotReadProperty) }
        return out
    }
    
    public func get(integerProperty key: CFString) throws -> Int32 {
        guard let out=getSafe(integerProperty: key) else { throw MIDIError(reason:.CannotReadProperty) }
        return out
    }
    
    public func get(booleanProperty key: CFString) throws -> Bool {
        guard let out=getSafe(integerProperty: key) else { throw MIDIError(reason:.CannotReadProperty) }
        return out==1
    }
    
    public var uid : MIDIUniqueID {
        return getSafe(integerProperty: kMIDIPropertyUniqueID) ?? kMIDIInvalidUniqueID
    }
    
    public var type : MIDIObjectType {
        guard let u=getSafe(integerProperty: kMIDIPropertyUniqueID) else { return .other }
        guard let (_,t) = try? u.getObject() else { return .other }
        return t
    }
}

extension MIDIUniqueID {
    public func getObject() throws -> (MIDIObjectRef,MIDIObjectType) {
        var obj : MIDIObjectRef = 0
        var type : MIDIObjectType = .entity
        let error=MIDIObjectFindByUniqueID(self, &obj,&type)
        if(error != noErr) { throw MIDIError(reason: .CannotLoadObject, status: error) }
        return (obj,type)
    }
}


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

extension MIDIObjectType {
    
    public var isExternal : Bool { return (rawValue&0x10) != 0 }
    public var isInternal : Bool { return (rawValue&0x10) == 0 }
    public var kind : MIDIObjectKind {
        if self == .other { return .other }
        else {
            let v=rawValue & 3
            return MIDIObjectKind.init(rawValue: v) ?? .other
        }
    }
    public var mode : MIDIObjectMode { return kind == .source ? .source : kind == .dest ? .destination : .other }
    public var location : MIDIObjectLocation { return (rawValue&0x10)==0 ? .int : .ext }
    
    public var isEndpoint : Bool { return kind == .source || kind == .dest }
    public var isEntity : Bool { return kind == .entity }
    public var isDevice : Bool { return kind == .device }
}
