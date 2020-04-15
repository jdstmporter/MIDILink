//
//  MIDIListener.swift
//  MIDI Utils
//
//  Created by Julian Porter on 14/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreFoundation
import CoreMIDI



func activityCallback(_ pkts: UnsafePointer<MIDIPacketList>,_ rCon: UnsafeMutableRawPointer?,_ sCon: UnsafeMutableRawPointer?) {
    
    let p : UnsafeMutablePointer<EndPointInfo>? = rCon?.bindMemory(to: EndPointInfo.self, capacity: 1)
    let info : EndPointInfo? = p?.pointee
    //debugPrint("Got \(pkts.pointee.numPackets) packets for \(info!.uid)")
    if info == nil { return }
    let packets=pkts.pointee
    info!.this.activity(packets: packets)
    
    
}

func linkCallback(_ pkts: UnsafePointer<MIDIPacketList>,_ rCon: UnsafeMutableRawPointer?,_ sCon: UnsafeMutableRawPointer?) {
    let p : UnsafeMutablePointer<MIDILinkState>? = rCon?.bindMemory(to: MIDILinkState.self, capacity: 1)
    let state : MIDILinkState? = p?.pointee
    if state == nil { return }
    
    try? state?.inject(packets: pkts)
}


public struct MIDILinkState {
    var destination: MIDIObjectRef
    var port : MIDIPortRef
    
    public init(destination: MIDIObjectRef = 0, port: MIDIPortRef = 0) {
        self.destination=destination
        self.port=port
    }
    
    public func inject(packets: UnsafePointer<MIDIPacketList>) throws {
        try WrapError(reason: .CannotSendPackets, block: { MIDISend(self.port,self.destination,packets) })
    }
}

public class MIDILink {
    private var client : MIDIClient!
    private var outputPort : MIDIOutputPort!
    private var inputPort : MIDIInputPort!
    private let _uid : String
    public var state : MIDILinkState!
    
    public init(source: MIDIBase, destination: MIDIBase) throws {
        try source.test(reason: .CannotCreateApplication, .source)
        try destination.test(reason: .CannotCreateApplication, .destination)

        client=try MIDIClient(endpoint: source)
        outputPort=try MIDIOutputPort(client: client, endpoint: destination)
        state=outputPort.state
        inputPort=try MIDIInputPort(client: client, endpoint: source, callback: linkCallback, state: &state)
        _uid=UUID().uuidString
    }
    
    deinit {
        try? unbind()
        inputPort=nil
        outputPort=nil
        client=nil
    }
    
    
    public var uid : String { return _uid }
    public func bind() throws { try inputPort.bind() }
    public func unbind() throws { try inputPort.unbind() }
    
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
    
    public var active : Bool { return thru != nil }
    public var description: String { return "\(source) -> \(sink) : \(active)" }
    
    
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
    public typealias Callback = (MIDIPacketList) -> Void
    private var client : MIDIClient!
    private var port : MIDIInputPort!
    public var uid : MIDIUniqueID = kMIDIInvalidUniqueID
    public var info : EndPointInfo!
    public static let MIDIListenerEventNotification = Notification.Name("MIDIListenerEventNotification")
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

