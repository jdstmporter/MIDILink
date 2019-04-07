//
//  MIDIObject.swift
//  MIDITools
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public struct MIDIError : Error {
    public let code : OSStatus
    public let message : String
    
    public init(_ code : OSStatus,message: String = "Error") {
        self.code=code
        self.message=message
    }
    
    public var localizedDescription: String { return "MIDIError : \(message) [code: \(code)]" }
}

public enum MIDIObjectKind : CaseIterable {
    case Endpoint
    case Entity
    case Device
    case Unknown
}

protocol MIDIObjectProtocol : Equatable {
    
    var uid : MIDIUniqueID { get }
    var object : MIDIObjectRef { get }
    var UID : MIDIUniqueID { get }
    var name : String? { get }
    var model : String? { get }
    var manufacturer : String? { get }
    
    var isValidEntity : Bool { get }
    
}

extension MIDIObjectProtocol {
    public static func ==(_ l : Self,_ r : Self) -> Bool {
        return l.uid == r.uid
    }
    public static func !=(_ l : Self,_ r : Self) -> Bool {
        return l.uid != r.uid
    }
    
    public var isValidEntity : Bool { return uid != kMIDIInvalidUniqueID }
}

public class MIDIObject : MIDIObjectProtocol {
    
    public let object : MIDIObjectRef
    public let uid : MIDIUniqueID
    public let kind : MIDIObjectType

    private var dictionary : [CFString:Any] = [:]
    private var array : [Any] = []
    
    internal var entity : MIDIObject? = nil
    internal var device : MIDIObject? = nil
   
    public init(uid u: MIDIUniqueID) throws {
        var obj : MIDIObjectRef = UInt32.zero
        var knd : MIDIObjectType = .other
        var error = MIDIObjectFindByUniqueID(u, &obj, &knd)
        if error != noErr { throw MIDIError(error,message: "Cannot get type for given UID") }
        
        uid=u
        kind=knd
        object=obj
        
        var unmanaged : Unmanaged<CFPropertyList>? = nil
        let ptr = UnsafeMutablePointer<Unmanaged<CFPropertyList>?>(&unmanaged)
        error=MIDIObjectGetProperties(object, ptr, false)
        if error != noErr { throw MIDIError(error,message: "Cannot get properties for MIDI Object") }
        if let props = unmanaged?.takeUnretainedValue() {
            let typeID = CFGetTypeID(props)
            if typeID == CFDictionaryGetTypeID() {
                let dict = props as! CFDictionary
                dictionary = dict as! Dictionary<CFString,Any>
            }
            else if typeID == CFArrayGetTypeID() {
                let arr = props as! CFArray
                array = arr as! Array<Any>
            }
        }
        else { throw MIDIError(kMIDIObjectNotFound,message: "Cannot get properties for MIDI Object") }
        
        if kind == .source || kind == .destination {
            var ent : MIDIEntityRef = UInt32.zero
            let error = MIDIEndpointGetEntity(object, &ent)
            if error != noErr {
                if error != kMIDIObjectNotFound {throw MIDIError(error,message: "Cannot get endpoint entity") }
            }
            else {
                entity = try MIDIObject(object: ent)
                device = entity?.device
            }
        }
        else if kind == .entity {
            entity = self
            var dev : MIDIDeviceRef = UInt32.zero
            let error = MIDIEntityGetDevice(object,&dev)
            if error != noErr {
                if error != kMIDIObjectNotFound { throw MIDIError(error,message: "Cannot get entity device") }
            }
            else {
                device = try MIDIObject(object: dev)
            }
        }
        else if kind == .device {
            device=self
        }
    }
    
    public convenience init(object : MIDIEntityRef) throws {
        var id : MIDIUniqueID = Int32.zero
        MIDIObjectGetIntegerProperty(object, kMIDIPropertyUniqueID, &id)
        try self.init(uid: id)
    }
    
    public func stringProperty(key: CFString) -> String? { return dictionary[key] as? String }
    public func integerProperty(key: CFString) -> Int32 { return dictionary[key] as? Int32 ?? -1 }
    public func booleanProperty(key: CFString) -> Bool { return integerProperty(key: key) == 1 }
    
    public var name : String? { return stringProperty(key: kMIDIPropertyName) }
    public var model : String? { return stringProperty(key: kMIDIPropertyModel) }
    public var manufacturer : String? { return stringProperty(key: kMIDIPropertyManufacturer) }
    public var UID : MIDIUniqueID { return integerProperty(key: kMIDIPropertyUniqueID) }
    
    

}
