//
//  MIDIPorts.swift
//  MIDIUtils
//
//  Created by Julian Porter on 17/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation
import CoreMIDI

fileprivate func stateChangeCallback(_ p: UnsafePointer<MIDINotification>, _ c: UnsafeMutableRawPointer?) {
    let notification = p.pointee
    let uid = c?.bindMemory(to: MIDIUniqueID.self, capacity: 1).pointee ?? kMIDIInvalidUniqueID
    debugPrint("\(uid) : MIDI notification \(notification.messageID.rawValue) and size \(notification.messageSize)")
}


    public class MIDIClient : CustomStringConvertible {
        var client: MIDIClientRef = 0
        var uid : MIDIUniqueID
        
        public init(endpoint: MIDIBase) throws {
            uid=endpoint.uid;
            try WrapError(reason: .CannotCreateApplication, block: { MIDIClientCreate(endpoint.targetName as CFString, stateChangeCallback, &self.uid, &self.client) })
        }
    
        deinit {
            MIDIClientDispose(client)
        }
    
        public var description: String { return String(format:"Client:%08x:%08x",client,uid) }
        public var cfDesc : CFString { return self.description as CFString }
        
        public func outputPort(description : String) throws -> MIDIPortRef {
            var port : MIDIPortRef = 0
            try WrapError(reason: .CannotCreateOutputPort, block: { MIDIOutputPortCreate(self.client, self.cfDesc, &port) })
            return port
        }
        public func inputPort(description : String, callback: @escaping MIDIReadProc, state: UnsafeMutableRawPointer?) throws -> MIDIPortRef {
            var port : MIDIPortRef = 0
            try WrapError(reason: .CannotCreateInputPort, block: { MIDIInputPortCreate(self.client, self.cfDesc, callback,state,&port) })
            return port
        }
    }




public class MIDIOutputPort :  CustomStringConvertible {
    
    var port : MIDIPortRef = 0
    var entity : MIDIObjectRef = 0
    
    public init(client: MIDIClient,endpoint: MIDIBase) throws {
        port=try client.outputPort(description: description)
        entity=endpoint.Object
    }
    
    deinit {
         MIDIPortDispose(port)
    }
    
    public func send(packets: UnsafePointer<MIDIPacketList>) throws {
        try WrapError(reason: .CannotSendPackets, block: { MIDISend(self.port,self.entity,packets )})
    }
    
    public var state : MIDILinkState { return MIDILinkState(destination: entity, port: port) }
    public var description: String { return String(format:"OutputPort:%08x:08x",entity,port) }
}

public class MIDIInputPort  :  CustomStringConvertible {
    
    var port : MIDIPortRef = 0
    var entity : MIDIObjectRef = 0
    
    public init(client: MIDIClient,endpoint: MIDIBase, callback: @escaping MIDIReadProc, state: UnsafeMutableRawPointer?) throws {
        entity=endpoint.Object
        port=try client.inputPort(description: description, callback: callback, state: state)
    }
    
    deinit {
        MIDIPortDispose(port)
    }
    
    public func bind() throws {
        try WrapError(reason: .CannotLinkInputPort, block: { MIDIPortConnectSource(self.port,self.entity,nil) })
    }
    
    public func unbind() throws {
        try WrapError(reason: .CannotUnlinkInputPort, block: { MIDIPortDisconnectSource(self.port,self.entity) })
    }
    
    public var description: String { return String(format:"InputPort:%08x:%08x",entity,port) }
    
}

