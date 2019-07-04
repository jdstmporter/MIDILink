//
//  LinkManager.swift
//  MIDIUtils
//
//  Created by Julian Porter on 24/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import MIDITools
import CoreMIDI

class LinkedEndpoints {
    
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
        func bind() throws {
            try link.bind()
            bound=true
        }
        func unbind() throws {
            bound=false
            try link.unbind()
        }
        
    }
    private var links : [Link] = []
    
    
    
    public subscript(_ vals : (MIDIUniqueID,MIDIUniqueID)) -> Link? {
        return (links.first { $0.from==vals.0 && $0.to==vals.1 })
    }
    public subscript(_ from : MIDIUniqueID,_ to : MIDIUniqueID) -> Link? {
       return (links.first { $0.from==from && $0.to==to })
    }
    
    public func ids(from: MIDIUniqueID) -> [MIDIUniqueID] {
        return links.compactMap { $0.from==from ? $0.to : nil }
    }
    public func ids(to: MIDIUniqueID) -> [MIDIUniqueID] {
        return links.compactMap { $0.to==to ? $0.from : nil }
    }
    public var count : Int { return links.count }
    public func count(from: MIDIUniqueID) -> Int { return ids(from: from).count }
    public func count(to: MIDIUniqueID) -> Int { return ids(to: to).count }
    
    public func linked(_ from : MIDIUniqueID,_ to : MIDIUniqueID) -> Bool { return self[from,to] != nil }
    public func linked(from: MIDIUniqueID) -> Bool { return count(from: from)>0 }
    public func linked(to: MIDIUniqueID) -> Bool { return count(to: to)>0 }
    
    public func create(from: MIDIBase,to: MIDIBase) throws -> Bool {
        if linked(from:from.uid) || linked(to:to.uid) { return false }
        try links.append(Link(from: from,to: to))
        return true
    }
    
    public func remove(from: MIDIBase,to: MIDIBase) {
        links.removeAll { $0.from==from.uid && $0.to==to.uid }
    }
    
    public func reset() { links.removeAll() }
    public func reset(from: [MIDIUniqueID]) { links.removeAll { !from.contains($0.from) } }
    public func reset(to: [MIDIUniqueID]) { links.removeAll { !to.contains($0.to) } }
    public func reset(_ all : [MIDIUniqueID]) {
        let aSet = Set(all)
        links.removeAll { aSet.isDisjoint(with: [$0.from,$0.to]) }
    }
}




protocol ILinkTableSource {
    
    var fromLabels : [MIDIUniqueID] { get }
    var toLabels : [MIDIUniqueID] { get }
    subscript(_ from: MIDIUniqueID,_ to: MIDIUniqueID) -> Bool { get }
    func link(from f: MIDIUniqueID,to t: MIDIUniqueID) throws
    func unlink(from f: MIDIUniqueID,to t: MIDIUniqueID) throws
    func tooltip(_ uid: MIDIUniqueID) -> String?
    func tooltip(_ uid: String) -> String?
    
}

protocol IMIDILinkManager {
    
    func load(from: [MIDIEndpoint],to: [MIDIEndpoint]) 
    subscript(_ from: MIDIEndpoint,_ to: MIDIEndpoint) -> MIDILink? { get }
    func link(from: MIDIEndpoint,to: MIDIEndpoint) throws
    func unlink(from: MIDIEndpoint,to: MIDIEndpoint) throws
    func clear()
    
}

protocol IMIDILinkEnumerator {
    
    var linked : [(MIDIUniqueID,MIDIUniqueID)] { get }
}

enum LinkTableError : Error {
    case LinkToItemAlreadyExists
    case LinkFromItemAlreadyExists
    case NoSuchEndpoint
    case NoSuchLink
}


class LinkManager : ILinkTableSource, IMIDILinkManager, IMIDILinkEnumerator {
    subscript(from: MIDIUniqueID, to: MIDIUniqueID) -> Bool {
        return self[from,to] != nil 
    }
    
    private subscript(_ from: MIDIUniqueID,_ to: MIDIUniqueID) -> MIDILink? {
        if !isValid(from:from,to:to) { return nil }
        return isLinked(from: from,to: to) ? links[to] : nil
    }
    
    public subscript(_ from: MIDIEndpoint,_ to: MIDIEndpoint) -> MIDILink? {
        return self[from.uid,to.uid]
    }
    
    
    
    
    
    static let MIDILinkTableChanged = NSNotification.Name("MIDILinkTableChangedEvent")
    static let MIDILinkCreated = NSNotification.Name("MIDILinkCreatedEvent")
    static let MIDILinkUndone = NSNotification.Name("MIDILinkUndoneEvent")
    
    
    
    private var links : [MIDIUniqueID: MIDILink] = [:]
    private var matrix : [MIDIUniqueID: MIDIUniqueID] = [:]
    private var froms : [MIDIEndpoint] = []
    private var tos : [MIDIEndpoint] = []
    
    public func load(from: [MIDIEndpoint], to: [MIDIEndpoint]) {
        links.removeAll()
        matrix.removeAll()
        froms=from
        tos=to
        to.forEach { matrix[$0.uid] = kMIDIInvalidUniqueID }
    }
   
    
    // Lots of utility methods
    
    private func isValid(from: MIDIUniqueID,to: MIDIUniqueID) -> Bool {
        return self.isValid(from: from) && self.isValid(to: to)
    }
    
    private func isValid(from: MIDIUniqueID) -> Bool {
        return self.froms.contains { $0.uid==from }
    }
    
    private func isValid(to: MIDIUniqueID) -> Bool {
        return self.tos.contains { $0.uid==to }
    }
    
    private func isValid(from: MIDIEndpoint,to: MIDIEndpoint) -> Bool {
        return self.isValid(from: from.uid,to: to.uid)
    }
    
    private func isValid(to: MIDIEndpoint) -> Bool {
        return self.isValid(to: to.uid)
    }
    
    private func isLinked(from: MIDIUniqueID,to: MIDIUniqueID) -> Bool {
        let lookup = matrix[to]
        return lookup != kMIDIInvalidUniqueID && lookup==from
    }
    
    private func isLinked(to: MIDIUniqueID) -> Bool {
        return matrix[to] != kMIDIInvalidUniqueID
    }
    
    private func isLinked(from: MIDIUniqueID) -> Bool {
        return matrix.filter { $0.value == from }.count>0
    }
    
    private func isLinked(from: MIDIEndpoint,to: MIDIEndpoint) -> Bool {
        return isLinked(from: from.uid,to: to.uid)
    }
    
    private func isLinked(to: MIDIEndpoint) -> Bool {
        return isLinked(to: to.uid)
    }
    
    private func isLinked(from: MIDIEndpoint) -> Bool {
        return isLinked(from: from.uid)
    }
    
    
    
    private func initialise() {
        links.removeAll()
        matrix.removeAll()
        tos.forEach { matrix[$0.uid] = kMIDIInvalidUniqueID }
    }
    
    
    // IMIDILinkManager protocol methods
    
    public func clear() {
        matrix.forEach { (arg) in
            let (to, from) = arg
            if from != kMIDIInvalidUniqueID {
                let link=links[to]
                try? link?.unbind()
            }
        }
        initialise()
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil)
    }

    

    public func link(from: MIDIEndpoint,to: MIDIEndpoint) throws {
        
        if !isValid(from: from, to: to) { throw LinkTableError.NoSuchEndpoint }
        if isLinked(to: to) { throw LinkTableError.LinkToItemAlreadyExists }
        if isLinked(from: from) { throw LinkTableError.LinkFromItemAlreadyExists }
        
        let link=try MIDILink(source: from, destination: to)
        try link.bind()
        
        links[to.uid]=link
        matrix[to.uid]=from.uid
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil, userInfo : ["from": from.uid, "to": to.uid, "linked" : true])
    }
    
    public func unlink(from: MIDIEndpoint,to: MIDIEndpoint) throws {
        if !isValid(to:to) { throw LinkTableError.NoSuchEndpoint }
        if !isLinked(from: from,to: to) { throw LinkTableError.NoSuchLink }
        
        let link = links[to.uid]
        if link==nil { throw LinkTableError.NoSuchLink }
        try link!.unbind()
        
        links.removeValue(forKey: to.uid)
        matrix[to.uid]=kMIDIInvalidUniqueID
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil, userInfo : ["from": from.uid, "to": to.uid, "linked" : false])
        
    }
    
    public func unlink(endpoint : MIDIEndpoint) throws {
        // unlink from or to this endpoint
    }
    
    // iLinkTableSource methods
    
    public var fromLabels : [MIDIUniqueID] { return froms.map { $0.uid } }
    
    public var toLabels : [MIDIUniqueID] { return tos.map { $0.uid } }
    
    
    
    public func link(from f: MIDIUniqueID,to t: MIDIUniqueID) throws {
        let from=froms.first { $0.uid==f }
        let to=tos.first { $0.uid==t }
        if from==nil || to==nil { throw LinkTableError.NoSuchEndpoint }
        try link(from: from!, to: to!)
    }
    
    public func unlink(from f: MIDIUniqueID,to t: MIDIUniqueID) throws {
        let from=froms.first { $0.uid==f }
        let to=tos.first { $0.uid==t }
        if from==nil || to==nil { throw LinkTableError.NoSuchEndpoint }
        try unlink(from: from!, to: to!)
    }
    
    public func tooltip(_ uid: MIDIUniqueID) -> String? {
        let from=froms.first { $0.uid==uid }
        if from != nil { return from!.name }
        let to=tos.first { $0.uid==uid }
        if to != nil { return to!.name }
        return nil
    }
    public func tooltip(_ label: String) -> String? {
        if let uid = MIDIUniqueID(label) { return tooltip(uid) }
        else { return nil }
    }
    
    // iMIDILinkeEnumerator methods
    
    public var linked : [(MIDIUniqueID,MIDIUniqueID)] {
        var out : [(MIDIUniqueID,MIDIUniqueID)] = []
        matrix.forEach { if isLinked(to: $0.key) { out.append(($0.value,$0.key)) }}
        return out
    }
    
    
}


