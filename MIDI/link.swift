//
//  link.swift
//  MIDI
//
//  Created by Julian Porter on 20/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

func linkCallback(_ pkts: UnsafePointer<MIDIPacketList>,_ rCon: UnsafeMutableRawPointer?,_ sCon: UnsafeMutableRawPointer?) {
    let p : UnsafeMutablePointer<MIDIOutputPort>? = rCon?.bindMemory(to: MIDIOutputPort.self, capacity: 1)
    let state : MIDIOutputPort? = p?.pointee
    if state == nil { return }
    
    try? state?.send(packets: pkts)
}


public class MIDILink {
    private var client : MIDIClient!
    private var outputPort : MIDIOutputPort!
    private var inputPort : MIDIInputPort!
    public private(set) var uid : String
    
    public init(source: MIDIBase, destination: MIDIBase) throws {
        try source.test(reason: .CannotCreateApplication, .source)
        try destination.test(reason: .CannotCreateApplication, .destination)

        client=try MIDIClient(endpoint: source)
        outputPort=try MIDIOutputPort(client: client, endpoint: destination)
        inputPort=try MIDIInputPort(client: client, endpoint: source, callback: linkCallback, state: &outputPort)
        uid=UUID().uuidString
    }
    
    deinit {
        try? unbind()
        inputPort=nil
        outputPort=nil
        client=nil
    }
    
    
    public func bind() throws { try inputPort.bind() }
    public func unbind() throws { try inputPort.unbind() }
    
}
