//
//  dictionary.swift
//  MIDI
//
//  Created by Julian Porter on 23/07/2021.
//  Copyright © 2021 JP Embedded Solutions. All rights reserved.
//

import Foundation


public typealias KVPair<K,V> = (key: K,value : V)


public class OrderedDictionary<K,V> : Sequence, CustomStringConvertible where K : Hashable, K : Nameable {
    fileprivate var dict : [K:V] = [:]
    fileprivate var order : [K] = []
    
    public struct Iterator : IteratorProtocol {
        public typealias Element=KVPair<K,V>
        private let dict : [K:V]
        private var it : Array<K>.Iterator
        
        public init(_ d : OrderedDictionary) {
            dict=d.dict
            it=d.order.makeIterator()
        }
        
        public mutating func next() -> OrderedDictionary<K, V>.Iterator.Element? {
            guard let k = it.next() else { return nil }
            guard let v = dict[k] else { return nil }
            return KVPair(k,v)
        }
        
    }
    
    public init() {}
    
    public init(_ e : Iterator.Element) { append(e) }
    public init(_ es : [Iterator.Element]) { append(es) }
    
    public func append(_ e : Iterator.Element) { self[e.key]=e.value }
    public func append(_ es : [Iterator.Element]) { es.forEach { self[$0.key] = $0.value } }
    public func append(_ d : OrderedDictionary<K,V>) {
        let items = d.map { $0 }
        self.append(items)
    }
    
    public var count : Int { return order.count }
    public func at(_ idx : Int) -> KVPair<K,V>? {
        guard idx>=0 && idx<count else { return nil }
        let k=order[idx]
        guard let v = dict[k] else { return nil }
        return KVPair(k,v)
    }
    public func index(of key : K) -> Int? { order.firstIndex(of: key) }
    public var isEmpty : Bool { order.isEmpty }
    public func removeAll() {
        dict.removeAll()
        order.removeAll()
    }
    public func remove(key: K) {
        order = order.filter { $0 != key }
        dict.removeValue(forKey: key)
    }
    
    
    public subscript(_ key : K) -> V? {
        get { dict[key] }
        set {
            if let value=newValue {
                if !order.contains(key) { order.append(key) }
                dict[key]=value
            }
            else {
                if order.contains(key) { order.removeAll { $0==key } }
                dict.removeValue(forKey: key)
            }
        }
    }
    
    public var keySet : Set<K> { Set(order) }
    public func has(_ k : K) -> Bool { order.contains(k) }
    
    public __consuming func makeIterator() -> OrderedDictionary<K, V>.Iterator { Iterator(self) }
    
    public var description: String { self.map { "\($0.key) = \($0.value)" }.joined(separator:", ") }
}

public typealias MIDIDict = OrderedDictionary<MIDITerms,Nameable>
public typealias Pair = MIDIDict.Element
