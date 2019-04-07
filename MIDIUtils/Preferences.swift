//
//  Preferences.swift
//  MIDIUtils
//
//  Created by Julian Porter on 26/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation
import AppKit


public protocol PreferenceListener {
    func preferencesChanged(_ preference : PreferencesReader) -> Void
    var hashValue : Int { get }
}

public class PreferenceFallbacks : Sequence {
    private static var the : PreferenceFallbacks?
    public typealias Keys = Dictionary<String,String>.Keys
    public let fallbacks : [String : String]
    public let keys : Keys
    
    public init(fallbackSource: String = "UserDefaults") {
        do {
            let url=Bundle.main.url(forResource: fallbackSource, withExtension: "plist")
            let data=try Data.init(contentsOf: url!)
            var format : PropertyListSerialization.PropertyListFormat = .xml
            fallbacks = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format) as! [String : String]
        }
        catch {
            fallbacks=[:]
        }
        keys = fallbacks.keys
    }
    
    public subscript(_ key : String) -> String? { return fallbacks[key] }
    
    public class Iterator : IteratorProtocol {
        private let fallbacks : [String : String]
        private let keys : Keys
        private var iterator : Keys.Iterator
        init(_ f : PreferenceFallbacks) {
            fallbacks=f.fallbacks
            keys=f.keys
            iterator=keys.makeIterator()
        }
        
        public func next() -> String? {
            let k=iterator.next()
            if k == nil { return nil }
            return fallbacks[k!]
        }
    }
    public func makeIterator() -> PreferenceFallbacks.Iterator {
        return Iterator(self)
    }
    
    func register(with d: UserDefaults) {
        d.register(defaults: fallbacks)
    }
    
    static func Get() -> PreferenceFallbacks {
        if the==nil { the=PreferenceFallbacks() }
        return the!
    }
    
    
}



public class PreferencesReader {
    internal var defaults : UserDefaults
    internal let bundleID : String?
    var fallbacks : PreferenceFallbacks
    var values : [String:String]
    var keys : PreferenceFallbacks.Keys
    var listeners : [PreferenceListener]
    
    
    public init() {
        listeners=[]
        bundleID = Bundle.main.bundleIdentifier
        defaults=UserDefaults()
        values=[:]
        fallbacks=PreferenceFallbacks.Get()
        keys = fallbacks.keys
        fallbacks.register(with: defaults)
        load()
        NotificationCenter.default.addObserver(self, selector: #selector(Preferences.synchronise), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    internal func load() {
        if bundleID==nil { return }
        let pd = defaults.persistentDomain(forName: bundleID!) ?? [:]
        keys.forEach { (key) in
            let p = (pd[key] as! String?) ?? fallbacks[key]
            if p != nil { values[key]=p! }
        }
        push()
    }
    
    @objc public func synchronise() {
        defaults.synchronize()
        load()
    }
    
    public func get<T>(key : String) -> T? where T : StringRepresentable  {
        return T.init(values[key] ?? "")
    }
    
    public func has(key : String) -> Bool {
        return keys.contains(key)
    }
    
    public func addListener(_ listener : PreferenceListener) {
        listeners.append(listener)
        listener.preferencesChanged(self)
    }
    
    public func removeListener(_ listener : PreferenceListener) {
        listeners=listeners.filter { $0.hashValue == listener.hashValue }
    }
    
    public func push() {
        listeners.forEach { $0.preferencesChanged(self)}
    }
}

public class Preferences : PreferencesReader {
    
    
    public override init() {
        super.init()
    }
    
      @objc public override func synchronise() {
        defaults.synchronize()
        let changes = keys.filter { values[$0] != (self[$0] as! String?) }
        if changes.count > 0 && bundleID != nil { load() }
        
    }
    
    public func save() {
        if bundleID != nil {
            defaults.setPersistentDomain(values, forName: Bundle.main.bundleIdentifier!)
        }
    }
    
    public func reset(_ sender : Any? = nil) {
        values=fallbacks.fallbacks.mapValues { $0 }
        push()
    }
    
    public subscript(_ key : String) -> Any? {
        get { return defaults.value(forKey: key) }
        set { defaults.setValue(newValue, forKey: key) }
    }
    
    public func set<T>(key : String,value : T?) where T : StringRepresentable {
        let d = value?.description
        if d != values[key] { self[key]=d }
    }
    
    
    
    
}




