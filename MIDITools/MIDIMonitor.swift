//
//  MIDIMonitor.swift
//  MIDITools
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public protocol MIDIDecoderClient {
    
    func link(decoder : MIDIDecoder)
    func unlink()
    
}

public class MIDIMonitor {
    public static let MIDIStatusChanged = Notification.Name("__MIDIStatusChanged")
    
    public enum Activity {
        case on
        case off
    }
    
    
    public typealias MIDIDataCallback = () -> ()
    public typealias MIDIActivityCallback = (Activity) -> ()
    
    internal var client : MIDIClient
    private var decoder : MIDIDecoder
    
    private var source : MIDIEndpoint? { return client.source }
    private var destination : MIDIEndpoint? { return client.destination }
    
    public var clientName : String { return client.name }
    public var sourceName : String? { return source?.name }
    public var destinationName : String? { return destination?.name }
    
    private var counter : AtomicInteger<Int32> = .zero
    public var active : Bool = false
    
    public var dataCallback : MIDIDataCallback? = nil
    public var activityCallback : MIDIActivityCallback? = nil
    
    public init(client : MIDIClient) throws {
        self.client=client
        self.decoder=try MIDIDecoder()
        self.client.callback = self.action
    }
    
    public var isSource : Bool { return source != nil }
    
    internal func monitor(packets : MIDIPacketList) {
        if decoder.count>8192 { decoder.reset() }
        decoder.load(packets)
    }
    
    public func link(_ client: MIDIDecoderClient) { client.link(decoder: decoder) }
    
    internal func action(_ packets : MIDIPacketList,_ status: OSStatus) {
        let error = (status==noErr) ? "" : " [error \(status)]"
        debugPrint("Got \(packets.numPackets)\(error) \(counter)")
        
        DispatchQueue.main.async {
            let new = self.counter.inc()
            self.active = new>0
            self.monitor(packets: packets)
            
            if new==1 {
                NotificationCenter.default.post(name: MIDIMonitor.MIDIStatusChanged, object: nil)
                self.activityCallback?(.on)
            }
            self.dataCallback?()
        }
        let time = DispatchTime.now()+DispatchTimeInterval.milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: time) {
            let new = self.counter.inc()
            self.active = new>0
            if new==0 {
                NotificationCenter.default.post(name: MIDIMonitor.MIDIStatusChanged, object: nil)
                self.activityCallback?(.off)
            }
        }
    }
    
}

public class MIDILink : MIDIMonitor {
    
    private var linked : Bool = false
    
    public init(name: String,source: MIDIObject,destination: MIDIObject) throws {
        let client = try MIDIClient(name: name)
        try client.connect(source: source)
        try client.connect(destination: destination)
        try super.init(client: client)
    }
    public convenience init(name: String,source: MIDIEndpoint,destination: MIDIEndpoint) throws {
        try self.init(name: name, source: source.thing, destination: destination.thing )
    }
    
    public func link() throws{
        if !linked {
            try self.client.link()
            linked=true
        }
    }
    public func unlink() throws {
        if linked {
            try self.client.unlink()
            linked=false
        }
    }
}

public class MIDIEndpointWrapper : MIDIMonitor {
    
    public let endpoint : MIDIEndpoint
    public convenience init(name: String,endpoint : MIDIObject) throws {
        try self.init(MIDIEndpoint(endpoint))
    }
    public init(_ endpoint : MIDIEndpoint) throws {
        let listener = try MIDIListener(name: endpoint.name ?? "name")
        try listener.connect(endpoint.thing)
        self.endpoint=endpoint
        try super.init(client: listener)
    }
    
    public override var sourceName : String { return endpoint.name ?? "endpoint" }
    public var uid : MIDIUniqueID { return endpoint.uid }
    public var mode : MIDIEndpoint.Mode { return endpoint.mode }
    
    
    public func setActivityCallback(_ cb : @escaping (MIDIUniqueID,MIDIMonitor.Activity) -> ()) {
        activityCallback = { cb(self.uid,$0) }
    }
    public func setDataCallback(_ cb : @escaping (MIDIUniqueID) -> ()) {
        dataCallback = { cb(self.uid) }
    }
    
}


