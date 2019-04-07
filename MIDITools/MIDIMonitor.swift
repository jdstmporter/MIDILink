//
//  MIDIMonitor.swift
//  MIDITools
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI


public class MIDIMonitor {
    public static let MIDIStatusChanged = Notification.Name("__MIDIStatusChanged")
    
    internal var client : MIDIClient
    private var decoder : MIDIDecoder
    
    private var source : MIDIEndpointDescription? { return client.source }
    private var destination : MIDIEndpointDescription? { return client.destination }
    
    public var clientName : String { return client.name }
    public var sourceName : String? { return source?.name }
    public var destinationName : String? { return destination?.name }
    
    private var counter : AtomicInteger<Int32> = .zero
    public var active : Bool = false
    
    public var callback : MIDIDecoderCallback? = nil
    
    public init(client : MIDIClient) throws {
        self.client=client
        self.decoder=try MIDIDecoder()
        self.client.callback = self.action
    }
    
    internal func monitor(packets : MIDIPacketList) {
        if decoder.count>8192 { decoder.reset() }
        decoder.load(packets)
        callback?()
    }
    
    internal func action(_ packets : MIDIPacketList,_ status: OSStatus) {
        let error = (status==noErr) ? "" : " [error \(status)]"
        debugPrint("Got \(packets.numPackets)\(error) \(counter)")
        
        DispatchQueue.main.async {
            let new = self.counter.inc()
            self.active = new>0
            if new==1 {
                NotificationCenter.default.post(name: MIDIMonitor.MIDIStatusChanged, object: nil)
            }
            self.monitor(packets: packets)
        }
        let time = DispatchTime.now()+DispatchTimeInterval.milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: time) {
            let new = self.counter.inc()
            self.active = new>0
            if new==0 {
                NotificationCenter.default.post(name: MIDIMonitor.MIDIStatusChanged, object: nil)
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
    
    private let endpoint : MIDIObject
    public init(name: String,endpoint : MIDIObject) throws {
        
        let listener = try MIDIListener(name: name)
        try listener.connect(endpoint)
        self.endpoint=endpoint
        try super.init(client: listener)
    }
    
    public override var sourceName : String { return endpoint.name ?? "endpoint" }
}


