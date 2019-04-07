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

extension MIDIUniqueID {
    var UID : String {
        return String(format:"%08x",UInt32(bitPattern: self))
    }
    
    init(string: String)  {
        let x = UInt32(string,radix: 16)
        if x==nil { self=kMIDIInvalidUniqueID }
        self=Int32(bitPattern: x!)
    }
}

protocol ILinkTableSource {
    
    var fromLabels : [String] { get }
    var toLabels : [String] { get }
    subscript(_ from: String,_ to: String) -> Bool { get }
    func link(from f: String,to t: String) throws
    func unlink(from f: String,to t: String) throws
    func tooltip(_ uid: String) -> String?
    
}

protocol IMIDILinkManager {
    
    init(froms: [MIDIEndPoint], tos: [MIDIEndPoint])
    subscript(_ from: MIDIEndPoint,_ to: MIDIEndPoint) -> MIDILink? { get }
    func link(from: MIDIEndPoint,to: MIDIEndPoint) throws
    func unlink(from: MIDIEndPoint,to: MIDIEndPoint) throws
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
    static let MIDILinkTableChanged = NSNotification.Name("MIDILinkTableChangedEvent")
    static let MIDILinkCreated = NSNotification.Name("MIDILinkCreatedEvent")
    static let MIDILinkUndone = NSNotification.Name("MIDILinkUndoneEvent")
    
    
    
    private var links : [MIDIUniqueID: MIDILink] = [:]
    private var matrix : [MIDIUniqueID: MIDIUniqueID] = [:]
    private var froms : [MIDIEndPoint]
    private var tos : [MIDIEndPoint]
    
    public required init(froms: [MIDIEndPoint], tos: [MIDIEndPoint]) {
        self.froms=froms
        self.tos=tos
        initialise()
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
    
    private func isValid(from: MIDIEndPoint,to: MIDIEndPoint) -> Bool {
        return self.isValid(from: from.uid,to: to.uid)
    }
    
    private func isValid(to: MIDIEndPoint) -> Bool {
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
    
    private func isLinked(from: MIDIEndPoint,to: MIDIEndPoint) -> Bool {
        return isLinked(from: from.uid,to: to.uid)
    }
    
    private func isLinked(to: MIDIEndPoint) -> Bool {
        return isLinked(to: to.uid)
    }
    
    private func isLinked(from: MIDIEndPoint) -> Bool {
        return isLinked(from: from.uid)
    }
    
    private subscript(_ from: MIDIUniqueID,_ to: MIDIUniqueID) -> MIDILink? {
        if !isValid(from:from,to:to) { return nil }
        return isLinked(from: from,to: to) ? links[to] : nil
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
                try? link?.unlink()
            }
        }
        initialise()
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil)
    }

    public subscript(_ from: MIDIEndPoint,_ to: MIDIEndPoint) -> MIDILink? {
        return self[from.uid,to.uid]
    }

    public func link(from: MIDIEndPoint,to: MIDIEndPoint) throws {
        
        if !isValid(from: from, to: to) { throw LinkTableError.NoSuchEndpoint }
        if isLinked(to: to) { throw LinkTableError.LinkToItemAlreadyExists }
        if isLinked(from: from) { throw LinkTableError.LinkFromItemAlreadyExists }
        
        let link=try MIDILink(source: from, destination: to)
        try link.bind()
        
        links[to.uid]=link
        matrix[to.uid]=from.uid
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil, userInfo : ["from": from.uid, "to": to.uid, "linked" : true])
    }
    
    public func unlink(from: MIDIEndPoint,to: MIDIEndPoint) throws {
        if !isValid(to:to) { throw LinkTableError.NoSuchEndpoint }
        if !isLinked(from: from,to: to) { throw LinkTableError.NoSuchLink }
        
        let link = links[to.uid]
        if link==nil { throw LinkTableError.NoSuchLink }
        try link!.unbind()
        
        links.removeValue(forKey: to.uid)
        matrix[to.uid]=kMIDIInvalidUniqueID
        NotificationCenter.default.post(name: LinkManager.MIDILinkTableChanged, object: nil, userInfo : ["from": from.uid, "to": to.uid, "linked" : false])
        
    }
    
    public func unlink(endpoint : MIDIEndPoint) throws {
        // unlink from or to this endpoint
    }
    
    // iLinkTableSource methods
    
    public var fromLabels : [String] { return froms.map { $0.UID } }
    
    public var toLabels : [String] { return tos.map { $0.UID } }
    
    public subscript(_ from: String,_ to: String) -> Bool {
        return self[MIDIUniqueID(string: from),MIDIUniqueID(string: to)] != nil
    }
    
    public func link(from f: String,to t: String) throws {
        let from=froms.first { $0.UID==f }
        let to=tos.first { $0.UID==t }
        if from==nil || to==nil { throw LinkTableError.NoSuchEndpoint }
        try link(from: from!, to: to!)
    }
    
    public func unlink(from f: String,to t: String) throws {
        let from=froms.first { $0.UID==f }
        let to=tos.first { $0.UID==t }
        if from==nil || to==nil { throw LinkTableError.NoSuchEndpoint }
        try unlink(from: from!, to: to!)
    }
    
    public func tooltip(_ uid: String) -> String? {
        let from=froms.first { $0.UID==uid }
        if from != nil { return from!.description }
        let to=tos.first { $0.UID==uid }
        if to != nil { return to!.description }
        return nil
    }
    
    // iMIDILinkeEnumerator methods
    
    public var linked : [(MIDIUniqueID,MIDIUniqueID)] {
        var out : [(MIDIUniqueID,MIDIUniqueID)] = []
        matrix.forEach { if isLinked(to: $0.key) { out.append(($0.value,$0.key)) }}
        return out
    }
    
    
}


