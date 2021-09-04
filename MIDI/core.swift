//
//  core.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public class MIDIDevice : MIDIBase {
    
    public init(fromUID u: MIDIUniqueID) throws {
        try super.init(u)
        if !type.isDevice { throw MIDIError(reason: .CannotLoadDevice)}
    }
    public convenience init(fromObject obj: MIDIObjectRef) throws {
        try self.init(fromUID: obj.uid)
    }
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

public func getMIDIObject(_ o : MIDIObjectRef) throws -> MIDIBase {
    let type=o.type
    if type.isEndpoint { return try MIDIEndpoint(fromUID: o.uid) }
    else if type.isEntity { return try MIDIEntity(fromUID: o.uid)}
    else if type.isDevice { return try MIDIDevice(fromUID: o.uid)}
    throw MIDIError(reason: .CannotLoadObject)
}


public class MIDI {
    private static var the : MIDI?
    
    public private(set) var _sources : [MIDIEndpoint] = []
    public private(set) var _destinations : [MIDIEndpoint] = []
    
    public init() throws {
        var n=MIDIGetNumberOfSources();
        for i in 0..<n  {
            let device=MIDIGetSource(i)
            if let object  = try getMIDIObject(device) as? MIDIEndpoint { _sources.append(object) }
        }
        n=MIDIGetNumberOfDestinations();
        for i in 0..<n  {
            let device=MIDIGetDestination(i)
            if let object = try getMIDIObject(device) as? MIDIEndpoint { _destinations.append(object) }
        }
    }
    public static var sources : [MIDIEndpoint] { the?._sources ?? [] }
    public static var destinations : [MIDIEndpoint] { the?._destinations ?? [] }
    public static var endpoints : Set<MIDIEndpoint> { Set(sources).union(destinations) }
    public static func scan() throws { the=try MIDI() }
}
