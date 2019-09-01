//
//  Collections.swift
//  MIDITools
//
//  Created by Julian Porter on 22/08/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

public class OffsetArray<T> {
    private var array: Array<T>
    private let offset : Int
    
    public init(_ array : Array<T>, offset : UInt = 0) {
        self.array = array
        self.offset = Int(offset)
    }
    
    public func shift(_ inc : UInt) -> OffsetArray<T> {
        return OffsetArray<T>(array, offset: UInt(offset)+inc)
    }
    
    public subscript(_ idx : Int) -> T { return array[offset+idx] }
    public var count : Int { return array.count-offset }
    
}


public class KVPair<K,V>  : CustomStringConvertible where K : Hashable {
    public let key : K
    public let value : V
    
    public init(_ key : K, _ value : V) {
        self.key=key
        self.value=value
    }
    public var description: String { return "\(key) = \(value)" }
}


public class OrderedDictionary<K,V> : Sequence where K : Hashable, K : CustomStringConvertible {
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
    
    public init(_ e : Iterator.Element) {
        append(e)
    }
    public init(_ es : [Iterator.Element]) {
        append(es)
    }
    
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
    
    public subscript(_ key : K) -> V? {
        get { return dict[key] }
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
    
    public __consuming func makeIterator() -> OrderedDictionary<K, V>.Iterator {
        return Iterator(self)
    }
}


