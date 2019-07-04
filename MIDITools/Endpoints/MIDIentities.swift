//
//  MIDIEntity.swift
//  MIDI Utils
//
//  Created by Julian Porter on 14/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI

public func WrapError (reason : MIDIError.Reason, block: () -> OSStatus ) throws {
    let error=block()
    if error != noErr { throw MIDIError(reason: reason, status: error) }
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

public typealias MIDIPair = (source:MIDIBase,destination:MIDIBase)



public class MIDIEndpoint : MIDIBase {
    
    
    
    
    
    internal var entity : MIDIEntity?
    
    public init(fromUID u: MIDIUniqueID) throws {
        try super.init(u)
        if !type.isEndpoint { throw MIDIError(reason: .CannotLoadEndPoint)}
        
        var e : MIDIObjectRef = 0
        let error=MIDIEndpointGetEntity(this, &e);
        if error==kMIDIObjectNotFound {
            entity=nil
        }
        else if error != noErr { throw MIDIError(reason: .CannotLoadEntity, status: error) }
        else {
            entity=try MIDIEntity(fromObject:e)
        }
    }
    public var device : MIDIDevice? { return entity?.device }
    
    
    
}
public class MIDIEntity : MIDIBase {
    
    internal var device : MIDIDevice?
    
    public init(fromUID u: MIDIUniqueID) throws {
        try super.init(u)
        if !type.isEntity { throw MIDIError(reason: .CannotLoadEntity)}
        
        var d : MIDIObjectRef = 0
        let error=MIDIEntityGetDevice(this, &d);
        if error==kMIDIObjectNotFound {
            device=nil
        }
        else if error != noErr { throw MIDIError(reason: .CannotLoadDevice, status: error) }
        else {
            device=try MIDIDevice(fromObject:d)
        }
        
        
    }
    public convenience init(fromObject obj: MIDIObjectRef) throws {
        try self.init(fromUID: obj.uid)
    }
}
public class MIDIDevice : MIDIBase {
    
    public init(fromUID u: MIDIUniqueID) throws {
        try super.init(u)
        if !type.isDevice { throw MIDIError(reason: .CannotLoadDevice)}
    }
    public convenience init(fromObject obj: MIDIObjectRef) throws {
        try self.init(fromUID: obj.uid)
    }
}

public func getMIDIObject(_ o : MIDIObjectRef) throws -> MIDIBase {
    let type=o.type
    if type.isEndpoint { return try MIDIEndpoint(fromUID: o.uid) }
    else if type.isEntity { return try MIDIEntity(fromUID: o.uid)}
    else if type.isDevice { return try MIDIDevice(fromUID: o.uid)}
    throw MIDIError(reason: .CannotLoadObject)
}

