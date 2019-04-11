//
//  MIDISystem.swift
//  MIDIManager
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import CoreMIDI

public enum MIDIDeviceType {
    case source
    case destination
    case all
}

public class MIDISystem {
    
    private var objects : [MIDIDeviceType : [MIDIEndpoint]]
    private var counts : [MIDIDeviceType : Int]
    private var lastEnumerated : Date
    
    
    
    public init() {
        self.objects=[:]
        self.counts = [:]
        self.lastEnumerated = Date.distantPast
    }
    
    public func enumerate() {
        let nSources = MIDIGetNumberOfSources()
        let nDestinations = MIDIGetNumberOfDestinations()
        let nAll = MIDIGetNumberOfDevices()
        
        let sources : [MIDIEndpoint] = (0..<nSources).compactMap { n in
            guard let obj = try? MIDIObject(object: MIDIGetSource(n)) else { return nil }
            return MIDIEndpoint(obj)
        }
        let destinations : [MIDIEndpoint] = (0..<nDestinations).compactMap { n in
            guard let obj = try? MIDIObject(object: MIDIGetDestination(n)) else { return nil }
            return MIDIEndpoint(obj) 
        }
        let all = destinations.reduce(sources) { (items,item) in
            if items.contains(item) { return items }
            var new = items
            new.append(item)
            return new
        }
        
        objects[.source] = sources
        objects[.destination] = destinations
        objects[.all] = all
        
        counts[.source] = nSources
        counts[.destination] = nDestinations
        counts[.all] = nAll
        
        lastEnumerated = Date()
    }
    
    public var sinceLastEnumerated : TimeInterval { return -lastEnumerated.timeIntervalSinceNow }
    
    public subscript(_ key : MIDIDeviceType) -> [MIDIEndpoint] { return objects[key] ?? [] }
    public func count(_ key : MIDIDeviceType) -> Int { return counts[key] ?? 0 }
    
    
    public static let common = MIDISystem()
}
