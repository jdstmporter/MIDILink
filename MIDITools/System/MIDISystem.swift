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
    
    public private(set) var _sources : [MIDIEndpoint] = []
    public private(set) var _destinations : [MIDIEndpoint] = []
    
    public init() throws {
        var n=MIDIGetNumberOfSources();
        for i in 0..<n  {
            let device=MIDIGetSource(i)
            if let object  = try getMIDIObject(device) as? MIDIEndpoint { _sources.append(object) }
        }
        n=MIDIGetNumberOfDestinations();
        for i in 0..<n  {
            let device=MIDIGetDestination(i)
            if let object = try getMIDIObject(device) as? MIDIEndpoint { _destinations.append(object) }
        }
    }
    public static var sources : [MIDIEndpoint] { the?._sources ?? [] }
    public static var destinations : [MIDIEndpoint] { the?._destinations ?? [] }
    public static var endpoints : Set<MIDIEndpoint> { Set(sources).union(destinations) }
    public static func scan() throws { the=try MIDISystem() }
}


