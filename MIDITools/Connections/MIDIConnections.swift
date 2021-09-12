//
//  connections.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



    



public class ActiveMIDIObject  {
    
    public var endpoint : MIDIBase
    
    public init(_ e : MIDIBase) throws {
        endpoint=e
    }
    
    public var name : String {  endpoint.name }
    public var model : String {  endpoint.model }
    public var manufacturer : String {  endpoint.manufacturer }
    public var UID : String {  endpoint.UID }
    public var isSource : Bool {  endpoint.isSource }
    public var isDestination : Bool {  endpoint.isDestination }
    public var mode : MIDIObjectMode {  endpoint.mode }
    public var uid : MIDIUniqueID {  endpoint.uid }
    public var Object : MIDIObjectRef {  endpoint.Object }
    
    public var isActive : Bool {  false }
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
        if decoder==nil { decoder=try? MIDIDecoder() }
        guard decoder != nil else { return }
        interface.link(decoder: decoder)
    }
    
    public func stopDecoding() {
        guard decoder != nil else { return }
        decoder.disconnect()
        decoder=nil
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
        let p=packets.filter { !filtered || $0.data.0 < 0xf8 } //packets.filter(realTime: filtered)
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
            //self.monitor(packets: p)
        })
        
    }
    
    public override var isActive: Bool {  active.value }
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



func activityCallback(_ pkts: UnsafePointer<MIDIPacketList>,_ rCon: UnsafeMutableRawPointer?,_ sCon: UnsafeMutableRawPointer?) {
    
    let p : UnsafeMutablePointer<EndPointInfo>? = rCon?.bindMemory(to: EndPointInfo.self, capacity: 1)
    let info : EndPointInfo? = p?.pointee
    //debugPrint("Got \(pkts.pointee.numPackets) packets for \(info!.uid)")
    if info == nil { return }
    let packets=pkts.pointee
    info!.this.activity(packets: packets)
    
    
}




public class MIDIThru : CustomStringConvertible {
    private var thru : MIDIThruConnectionRef?
    public let source : MIDIUniqueID
    public let sink : MIDIUniqueID
    
    private static let ownerID = "solutions.jpembedded.midi"
    private static let channelMap : (UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8,UInt8) = (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15)
    private static let transform = MIDITransform(transform: .none, param: 0)
    private static let noEndpoint = MIDIThruConnectionEndpoint(endpointRef: 0, uniqueID: kMIDIInvalidUniqueID)
    
    public init(source : MIDIBase, sink: MIDIBase) throws {
        
        let sources = (source.thru,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint)
        let destinations = (sink.thru,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint,MIDIThru.noEndpoint)
        
        var params = MIDIThruConnectionParams(version: 0,
                                              numSources: 1, sources: sources,
                                              numDestinations: 1, destinations: destinations,
                                              channelMap: MIDIThru.channelMap,
                                              lowVelocity: 0, highVelocity: 255, lowNote: 0, highNote: 255,
                                              noteNumber: MIDIThru.transform, velocity: MIDIThru.transform, keyPressure: MIDIThru.transform, channelPressure: MIDIThru.transform, programChange: MIDIThru.transform, pitchBend: MIDIThru.transform,
                                              filterOutSysEx: 0, filterOutMTC: 0, filterOutBeatClock: 0, filterOutTuneRequest: 0,
                                              reserved2: (0,0,0),
                                              filterOutAllControls: 0, numControlTransforms: 0, numMaps: 0, reserved3: (0,0,0,0))
        
        let size = MemoryLayout<MIDIThruConnectionParams>.size(ofValue: params)
        let data = withUnsafeMutableBytes(of: &params) { Data(bytes: $0.baseAddress!, count: size) }
        
        var ref : MIDIThruConnectionRef = 0
        let out = MIDIThruConnectionCreate(MIDIThru.ownerID as CFString, data as CFData, &ref)
        if out != noErr { throw MIDIError(status: out) }
        self.thru = ref
        self.source = source.uid
        self.sink = sink.uid
    }
    
    deinit {
        if let t=thru { MIDIThruConnectionDispose(t) }
    }
    
    public func stop() {
        if let t=thru { MIDIThruConnectionDispose(t) }
        thru=nil
    }
    
    public var active : Bool {  thru != nil }
    public var description: String {  "\(source) -> \(sink) : \(active)" }
    
    
}




public struct EndPointInfo {
    let this : MIDIListener
    let uid : MIDIUniqueID
    
    init(_ me : MIDIListener) {
        this=me
        uid=me.uid
    }
}

public class MIDIListener {
    public static let MIDIListenerEventNotification = Notification.Name("MIDIListenerEventNotification")
    public typealias Callback = (MIDIPacketList) -> Void
    
    private var client : MIDIClient!
    private var port : MIDIInputPort!
    public var uid : MIDIUniqueID = kMIDIInvalidUniqueID
    public var info : EndPointInfo!
    
    private var last : MIDITimeStamp = 0
    
    public var callback : Callback? = nil
    public let endpoint : MIDIBase
    
    public init(endpoint: MIDIBase) throws {
        try endpoint.test(reason: .CannotCreateApplication, .source)
        self.endpoint=endpoint
        uid=endpoint.uid
        client=try MIDIClient(endpoint: endpoint)
        info = EndPointInfo(self)
        port = try MIDIInputPort(client: client,endpoint: endpoint, callback: activityCallback, state: &info)
        
    }
    
    public var name : String { return endpoint.name }
    
    deinit {
        try? unbind()
        port=nil
        client=nil
        info=nil
    }
    
    public func bind() throws { try port.bind() }
    
    public func unbind() throws { try port.unbind() }
    
    public func activity(packets : MIDIPacketList) {
        //debugPrint("Processing packets on \(uid)")
        NotificationCenter.default.post(name: MIDIListener.MIDIListenerEventNotification, object: nil,
                                        userInfo: ["uid" : info!.uid as Any, "packets" : packets as Any])
        callback?(packets)
    }
    
}









