//
//  dict.swift
//  MIDIManager
//
//  Created by Julian Porter on 06/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public class OrderedDictionary<K,V> : Sequence where K : Hashable {
    fileprivate var dict : [K:V]
    fileprivate var keys : [K]
    
    public class Iterator : IteratorProtocol {
        public typealias Element = (key: K,value : V)
        
        private let dict : [K:V]
        private let keys : [K]
        private var index : Int
        
        public init(_ dict : OrderedDictionary<K,V>) {
            self.dict=dict.dict
            self.keys=dict.keys
            self.index=0
        }
        public func next() -> Element? {
            if index<keys.count {
                let key=keys[index]
                index += 1
                return Element(key,dict[key]!)
            }
            else { return nil }
        }
        
    }
    
    public init() {
        dict=[:]
        keys=[]
    }
    public convenience init(_ items : [(K,V)]) {
        self.init()
        items.forEach { self[$0.0] = $0.1 }
    }
    
    public var count : Int { return keys.count }
    public var isEmpty : Bool { return keys.isEmpty }
    public func removeAll() {
        dict.removeAll()
        keys.removeAll()
    }
    public subscript(_ key : K) -> V? {
        get {
            return dict[key]
        }
        set {
            if let nv=newValue {
                if !keys.contains(key) {
                    keys.append(key)
                }
                dict[key]=nv
            }
        }
    }
    public __consuming func makeIterator() -> OrderedDictionary<K, V>.Iterator {
        return Iterator(self)
    }
    public func at(_ index : Int) -> V? { return dict[keys[index]] }
    
    
}
