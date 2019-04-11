//
//  MIDIEndpoint.swift
//  MIDITools
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public class MIDIEndpoint : MIDIObjectProtocol {
    
    public enum Mode {
        case source
        case destination
        case unknown
        
        public init(_ kind: MIDIObjectType) {
            switch kind {
            case .source:
                self = .source
                break
            case .destination:
                self = .destination
                break
            default:
                self = .unknown
            }
        }
    }
    
    
    public let kind : MIDIObjectKind
    public let thing : MIDIObject
    
    public init(_ obj : MIDIObject) {
        self.thing=obj
        switch obj.kind {
        case .source, .destination:
            self.kind = .Endpoint
        case .device:
            self.kind = .Device
        case .entity:
            self.kind = .Entity
        default:
            self.kind = .Unknown
        }
        
    }
    
    public var mode : Mode { return Mode(self.thing.kind) } 

    
    public var object: MIDIObjectRef { return thing.object }
    public var uid: MIDIUniqueID { return thing.uid }
    public var name: String? { return thing.name }
    public var manufacturer: String? { return thing.manufacturer }
    public var model: String? { return thing.model }
    
    public var typeName : String { return "\(kind)" }
    
    public subscript(_ key : CFString) -> String? {
        if let s = thing.stringProperty(key: key) { return s }
        else if let s = thing.entity?.stringProperty(key: key) { return s }
        else if let s = thing.device?.stringProperty(key: key) { return s }
        return nil
    }
    
    
    
}

public struct MIDIEndpointPair {
    public let source : MIDIObject?
    public let destination : MIDIObject?
 
    public init(source: MIDIObject? = nil, destination: MIDIObject? = nil) {
        self.source = source
        self.destination = destination
    }
}


