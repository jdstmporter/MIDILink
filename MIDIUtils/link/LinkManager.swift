//
//  LinkManager.swift
//  MIDIUtils
//
//  Created by Julian Porter on 24/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

import CoreMIDI

public class LinkedEndpoints {
    
    public class Link {
        let from: MIDIUniqueID
        let to : MIDIUniqueID
        let link: MIDILink
        var bound : Bool
     
        init(from: MIDIBase,to: MIDIBase) throws {
            self.from=from.uid
            self.to=to.uid
            self.link=try MIDILink(source: from, destination: to)
            self.bound=false
        }
        deinit {
            if self.bound { try? self.link.unbind() }
        }
        @discardableResult func bind() throws -> Link {
            try link.bind()
            bound=true
            return self
        }
        @discardableResult func unbind() throws -> Link {
            bound=false
            try link.unbind()
            return self
        }
        
    }
    private var links : [Link] = []
    
    
    
    public subscript(_ vals : (MIDIUniqueID,MIDIUniqueID)) -> Link? {
        return (links.first { $0.from==vals.0 && $0.to==vals.1 })
    }
    public subscript(_ from : MIDIUniqueID,_ to : MIDIUniqueID) -> Link? {
       return (links.first { $0.from==from && $0.to==to })
    }
    
    public func ids(from: MIDIUniqueID? = nil) -> [MIDIUniqueID] {
        return links.compactMap { $0.from==from ? $0.to : nil }
    }
    public func ids(to: MIDIUniqueID? = nil) -> [MIDIUniqueID] {
        return links.compactMap { $0.to==to ? $0.from : nil }
    }
    public var count : Int { return links.count }
    public func count(from: MIDIUniqueID) -> Int { return ids(from: from).count }
    public func count(to: MIDIUniqueID) -> Int { return ids(to: to).count }
    
    public func linked(_ from : MIDIUniqueID?,_ to : MIDIUniqueID?) -> Bool { return self[from ?? kMIDIInvalidUniqueID,to ?? kMIDIInvalidUniqueID] != nil }
    public func linked(from: MIDIUniqueID?) -> Bool { return count(from: from ?? kMIDIInvalidUniqueID)>0 }
    public func linked(to: MIDIUniqueID?) -> Bool { return count(to: to ?? kMIDIInvalidUniqueID)>0 }
    
    public func create(from: MIDIBase,to: MIDIBase) throws {
        if linked(from:from.uid) || linked(to:to.uid) { return }
        let link = try Link(from: from,to: to)
        try link.bind()
        links.append(link)
    }
    
    public func remove(from: MIDIUniqueID,to: MIDIUniqueID) throws {
        if let link = self[from,to] {
            try link.unbind()
            links.removeAll { $0.from==from && $0.to==to }
        }
    }
    public func remove(from: MIDIUniqueID) throws {
        try ids(from: from).forEach { try self[from,$0]?.unbind() }
        links.removeAll { $0.from==from }
    }
    public func remove(to: MIDIUniqueID) throws {
        try ids(to: to).forEach { try self[$0,to]?.unbind() }
        links.removeAll { $0.to==to }
    }
    public func remove(from: MIDIBase,to: MIDIBase) throws {
        try remove(from: from.uid,to: to.uid)
    }
    
    public func reset() { links.removeAll() }
    public func reset(from: [MIDIUniqueID]) { links.removeAll { !from.contains($0.from) } }
    public func reset(to: [MIDIUniqueID]) { links.removeAll { !to.contains($0.to) } }
    public func reset(_ all : [MIDIUniqueID]) {
        let aSet = Set(all)
        links.removeAll { aSet.isDisjoint(with: [$0.from,$0.to]) }
    }
}


