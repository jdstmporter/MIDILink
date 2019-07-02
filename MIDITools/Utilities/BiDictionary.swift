//
//  BiDictionary.swift
//  MIDIUtils
//
//  Created by Julian Porter on 09/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation



public class RODict<K : Hashable,V : Hashable> : Sequence {
    
    public typealias Iterator=OrderedDictionary<K,V>.Iterator
    private var dict : OrderedDictionary<K,V>
    
    public init() {
        dict=OrderedDictionary<K,V>()
    }
    
    internal func set(_ key : K,_ value : V) {
        dict[key]=value
    }
    
    public subscript(_ key: K) -> V? {
        return dict[key]
    }
    
    public func makeIterator() -> Iterator {
        return dict.makeIterator()
    }
    
    public var values : [V] {
        return dict.map { $0.1! }
    }
    
    public var keys : [K] {
        return dict.map { $0.0 }
    }
    
    public var count : Int { return dict.count }
}

public class BiDictionary<K : Hashable,V : Hashable>
    where K : Comparable {
    
    private var forward : RODict<K,V>
    private var backward : RODict<V,K>
    
    public init() {
        forward=RODict<K,V>()
        backward=RODict<V,K>()
    }
    
    public init(_ dict: [K:V]) {
        forward=RODict<K,V>()
        backward=RODict<V,K>()
        let keys=[K](dict.keys).sorted()
        keys.forEach { insert(from: $0, to: dict[$0]!) }
    }
    
    public init(_ pairs: [(K,V)]) {
        forward=RODict<K,V>()
        backward=RODict<V,K>()
        let p=pairs.sorted(by: { $0.0 < $1.0 })
        p.forEach { insert(from: $0.0, to: $0.1) }
    }
    
    public var count : Int { return forward.count }
    
    
    public subscript(_ k: K) -> V? {
        return forward[k]
    }
    
    public var rev : RODict<V,K> { return backward }
    public var fwd : RODict<K,V> { return forward }
    
    
    private func insert(from: K, to: V) {
        forward.set(from,to)
        backward.set(to,from)
    }
}
