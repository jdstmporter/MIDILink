//
//  client.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

fileprivate func stateChangeCallback(_ p: UnsafePointer<MIDINotification>, _ c: UnsafeMutableRawPointer?) {
    let notification = p.pointee
    let uid = c?.bindMemory(to: MIDIUniqueID.self, capacity: 1).pointee ?? kMIDIInvalidUniqueID
    debugPrint("\(uid) : MIDI notification \(notification.messageID.rawValue) and size \(notification.messageSize)")
}


public class MIDIClient : CustomStringConvertible {
    var endpoint : MIDIBase
    public private(set) var client: MIDIClientRef = 0
    public private(set) var uid : MIDIUniqueID
    
    public init(endpoint e: MIDIBase) throws {
        endpoint=e
        uid=e.uid
        try MIDIError.Try(reason: .CannotCreateApplication, block: { MIDIClientCreate(self.endpoint.targetName as CFString, stateChangeCallback, &self.uid, &self.client) })
    }
    deinit { MIDIClientDispose(client) }

    public var description: String { String(format:"Client:%08x:%08x",client,uid) }
    public var cfDesc : CFString { self.description as CFString }
    
    public func outputPort(description : String) throws -> MIDIPortRef {
        var port : MIDIPortRef = 0
        try MIDIError.Try(reason: .CannotCreateOutputPort, block: { MIDIOutputPortCreate(self.client, self.cfDesc, &port) })
        return port
    }
    public func inputPort(description : String, callback: @escaping MIDIReadProc, state: UnsafeMutableRawPointer?) throws -> MIDIPortRef {
        var port : MIDIPortRef = 0
        try MIDIError.Try(reason: .CannotCreateInputPort, block: { MIDIInputPortCreate(self.client, self.cfDesc, callback,state,&port) })
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
    deinit { MIDIPortDispose(port) }
    
    public func send(packets: UnsafePointer<MIDIPacketList>) throws {
        try MIDIError.Try(reason: .CannotSendPackets, block: { MIDISend(self.port,self.entity,packets )})
    }
    
    public var description: String { String(format:"OutputPort:%08x:08x",entity,port) }
}

public class MIDIInputPort  :  CustomStringConvertible {
    
    var port : MIDIPortRef = 0
    var entity : MIDIObjectRef = 0
    
    public init(client: MIDIClient,endpoint: MIDIBase, callback: @escaping MIDIReadProc, state: UnsafeMutableRawPointer?) throws {
        entity=endpoint.Object
        port=try client.inputPort(description: description, callback: callback, state: state)
    }
    deinit { MIDIPortDispose(port) }
    
    public func bind() throws {
        try MIDIError.Try(reason: .CannotLinkInputPort, block: { MIDIPortConnectSource(self.port,self.entity,nil) })
    }
    
    public func unbind() throws {
        try MIDIError.Try(reason: .CannotUnlinkInputPort, block: { MIDIPortDisconnectSource(self.port,self.entity) })
    }
    
    public var description: String { String(format:"InputPort:%08x:%08x",entity,port) }
    
}

