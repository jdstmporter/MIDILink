//
//  MIDIClient.swift
//  MIDITools
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


typealias MIDICallback = (MIDIPacketList,OSStatus) -> ()

fileprivate func MIDINotifier(_ message: UnsafePointer<MIDINotification>, _ ptr: UnsafeMutableRawPointer?) {}

fileprivate func processingCallback(_ packets : UnsafePointer<MIDIPacketList>,
                                        _ clientContext : UnsafeMutableRawPointer?,
                                        _ sourceContext : UnsafeMutableRawPointer?) {
    if let client : MIDIClient = clientContext?.bindMemory(to: MIDIClient.self, capacity: 1).pointee {
        var error : OSStatus = noErr
        if let destination=client.destination {
            error = MIDISend(client.destinationPort,destination.object,packets)
        }
        DispatchQueue.main.async { client.callback?(packets.pointee,error) }
    }
}

public class MIDIClient {
    
    
    
    private var raw : MIDIClientRef = 0
    public let name : String
    private var activeSince : Date?
    internal var callback : MIDICallback?
    
    internal var source : MIDIEndpointDescription?
    internal var destination : MIDIEndpointDescription?
    internal var sourcePort : MIDIPortRef = 0
    internal var destinationPort : MIDIPortRef = 0
    
    public init(name : String) throws {
        self.name=name
        
        var raw : MIDIClientRef = 0
        var this=self
        let selfRef = UnsafeMutableRawPointer(&this)
        let error = MIDIClientCreate(name as CFString, MIDINotifier, selfRef, &raw)
        if error != noErr { throw MIDIError(error, message: "Cannot create application \(name)") }
        self.raw=raw
        self.callback = {(p,e) in self.action(p,e) }
        
    }
    
    deinit {
        MIDIClientDispose(raw)
        MIDIPortDispose(sourcePort)
        MIDIPortDispose(destinationPort)
    }
    
    public func connect(destination: MIDIObject?) throws {
        var portName : String = ""
        if let destination=destination {
            self.destination=MIDIEndpointDescription(destination)
            portName = destination.name ?? "destination"
        }
        else { self.destination=nil }
        var port : MIDIPortRef = 0
        let error = MIDIOutputPortCreate(raw, portName as CFString, &port)
        if error != noErr { throw MIDIError(error, message: "Cannot create output port") }
        destinationPort = port
    }
    
    public func connect(source: MIDIObject?) throws {
        var portName : String = ""
        if let source=source {
            self.source=MIDIEndpointDescription(source)
            portName = source.name ?? "source"
        }
        else { self.source=nil }
        var this = self
        let selfRef = UnsafeMutableRawPointer(&this)
        var port : MIDIPortRef = 0
        let error = MIDIInputPortCreate(raw, portName as CFString, processingCallback,selfRef,&port)
        if error != noErr { throw MIDIError(error, message: "Cannot create input port") }
        sourcePort = port
    }
    
    public func link() throws {
        if let source = self.source {
            let error = MIDIPortConnectSource(sourcePort, source.object, nil)
            if error != noErr { throw MIDIError(error,message: "Cannot link input port") }
        }
    }
    public func unlink() throws {
        if let source = self.source {
            let error = MIDIPortDisconnectSource(sourcePort, source.object)
            if error != noErr { throw MIDIError(error,message: "Cannot unlink input port") }
        }
    }
    
    
    internal func action(_ packets : MIDIPacketList, _ status: OSStatus) {
        let error = status==noErr ? "" : " [error \(status)]"
        debugPrint("Got \(packets.numPackets)\(error)")
        activeSince=Date()
    }
    
    public var isLink : Bool { return false }
}

public class MIDIListener : MIDIClient {
    
    public func connect(_ obj: MIDIObject) throws {
        try connect(source: obj)
        self.destination=nil
        try link()
    }
    
    public func disconnect() throws {
        try unlink()
    }
}

public class MIDIInjector : MIDIClient {
    
    public func connect(_ obj: MIDIObject) throws {
        self.source=nil
        try connect(destination: obj)
    }
    
    public func disconnect() throws {
        let error = MIDIPortDispose(destinationPort)
        if error != noErr { throw MIDIError(error, message: "Cannot dispose of output port") }
    }
    
    public func inject(packets : MIDIPacketList) throws {
        if let destination=self.destination {
            var pkts = packets
            let error = MIDISend(destinationPort,destination.object,&pkts)
            if error != noErr { throw MIDIError(error, message: "Cannot snd packets") }
        }
    }
}


