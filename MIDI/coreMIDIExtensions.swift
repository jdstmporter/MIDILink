//
//  coreMIDIExtensions.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

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
