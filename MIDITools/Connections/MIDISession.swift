//
//  Wrapper.swift
//  MIDI Utils
//
//  Created by Julian Porter on 15/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreFoundation
import CoreMIDI



public class ActiveMIDIObject  {
    
    public var endpoint : MIDIBase
    
    public init(_ e : MIDIBase) throws {
        endpoint=e
    }
    
    public var name : String { return endpoint.name }
    public var model : String { return endpoint.model }
    public var manufacturer : String { return endpoint.manufacturer }
    public var UID : String { return endpoint.UID }
    public var isSource : Bool { return endpoint.isSource }
    public var isDestination : Bool { return endpoint.isDestination }
    public var mode : MIDIObjectMode { return endpoint.mode }
    public var uid : MIDIUniqueID { return endpoint.uid }
    public var Object : MIDIObjectRef { return endpoint.Object }
    
    public var isActive : Bool { return false }
    public func process(_ packets: MIDIPacketList) {}
    public func inject(_ packets: MIDIPacketList) throws {}
    
    public static func make(_ endpoint : MIDIBase) throws -> ActiveMIDIObject {
        switch endpoint.mode {
        case .source:
            return try MIDISource(endpoint)
        case .destination:
            return try MIDIDestination(endpoint)
        default:
            throw MIDIError(reason: .CannotCreateApplication)
        }
    }
    
}

public class MIDIDestination : ActiveMIDIObject {

    public var port : MIDIOutputPort!
    
    public override init(_ e: MIDIBase) throws {
        try e.test(reason: .CannotCreateApplication, .destination)
        try super.init(e)
        let client=try MIDIClient(endpoint: endpoint)
        port = try MIDIOutputPort(client: client, endpoint: endpoint)
        
    }
    
    public override func inject(_ packets: MIDIPacketList) throws {
        var p=packets
        try port.send(packets: &p)
    }
}




public class MIDISource : ActiveMIDIObject {
    public typealias Callback = ([MIDIPacket]) -> Void
    public typealias ActivityCallback = (MIDIUniqueID,Bool) -> Void
    
    private var listener : MIDIListener! = nil
    private var decoder : MIDIDecoder! = nil
    private var counter : AtomicInteger
    private var active : AtomicBoolean
    internal var filtered : Bool = true
    
    public var postProcessCallback : Callback?
    public var activityCallback : ActivityCallback?
    
    public override init(_ e: MIDIBase) throws {
        try e.test(reason: .CannotCreateApplication, .source)
        counter=AtomicInteger()
        active=AtomicBoolean()
        try super.init(e)
        
        listener=try MIDIListener(endpoint: endpoint)
        listener.callback = { self.process($0) }
        try listener.bind()
    }
    
    deinit {
        listener.callback = nil
        try? listener.unbind()
    }
    
    public func startDecoding(interface : MIDIDecoderInterface) {
        if decoder==nil {
            decoder=MIDIDecoder()
            interface.link(decoder: decoder)
        }
    }
    
    public func stopDecoding() {
        if decoder != nil {
            decoder.disconnect()
            decoder=nil
        }
    }
    

    
    private func monitor(packets: [MIDIPacket]) {
        if decoder != nil {
            if decoder.count > 8192 { decoder.reset() }
            decoder.load(packets: packets)
        }
        postProcessCallback?(packets)
    }
    
    public override func process(_ packets : MIDIPacketList) {
        if !isSource { return }
        let p=packets.filter(realTime: filtered)
        if p.count==0 { return }
        
        DispatchQueue.main.async {
            let new=self.counter.increment()
            self.active.value = new>0
            //debugPrint("FIRE \(new) \(self.active.value)")
            if new==1 {
                self.activityCallback?(self.endpoint.uid,true)
            }
            self.monitor(packets: p)
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.getTime(fromNowInSeconds: 0.25), execute: {
            let new=self.counter.decrement()
            self.active.value=new>0
            //debugPrint("UNFIRE \(new) \(self.active.value)")
            if new==0 {
                self.activityCallback?(self.endpoint.uid,false)
            }
            self.monitor(packets: p)
        })
        
    }
    
    public override var isActive: Bool { return active.value }
}

public func activateMIDIObject(_ endpoint: MIDIBase) throws -> ActiveMIDIObject {
    switch endpoint.mode {
    case .source:
        return try MIDISource(endpoint)
    case .destination:
        return try MIDIDestination(endpoint)
    default:
        throw MIDIError(reason: .CannotCreateApplication)
    }
}







