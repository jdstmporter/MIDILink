//
//  MIDISystem.swift
//  MIDI Utils
//
//  Created by Julian Porter on 14/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI



public class MIDISystem {
    
    private static var the : MIDISystem?
    
    public var sources_ : [MIDIEndpoint] = []
    public var destinations_ : [MIDIEndpoint] = []
    
    public init() throws {
        
        var n=MIDIGetNumberOfSources();
        for i in 0..<n  {
            let device=MIDIGetSource(i)
            if let object  = try getMIDIObject(device) as? MIDIEndpoint { sources_.append(object) }
        }

        n=MIDIGetNumberOfDestinations();
        for i in 0..<n  {
            let device=MIDIGetDestination(i)
            if let object = try getMIDIObject(device) as? MIDIEndpoint { destinations_.append(object) }
        }
    }
    
    public var sources : [MIDIEndpoint] {
        return sources_
    }
    public var destinations : [MIDIEndpoint] {
        return destinations_
    }
    
    public var endpoints : Set<MIDIEndpoint> {
        return Set(sources).union(destinations)
    }
    
    public static func scan() throws {
        the=try MIDISystem()
    }
}

