//
//  OrderedDictionary.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

internal func DictFromPairs<K,V>(_ pairs: [(K,V)]) -> [K:V] {
    var d = [K:V]()
    pairs.forEach { d[$0.0]=$0.1 }
    return d
}
internal func DictToPairs<K,V>(_ d : [K:V]) -> [(K,V)] {
    return d.map { ($0.key,$0.value) }
}

public struct OrderedDictionaryIterator<Key : Hashable,Value> : IteratorProtocol {
    private let d : OrderedDictionary<Key,Value>
    private var index : Int
    
    init(_ d: OrderedDictionary<Key,Value>) {
        self.d=d
        self.index=0
    }
    
    public mutating func next() -> (Key,Value?)? {
        if index<d.count {
            let key=d.order[index]
            let value=d.dict[key]
            index+=1
            return (key,value)
        }
        return nil
    }
}

public class OrderedDictionary<Key : Hashable,Value> : Sequence, CustomStringConvertible {
    
    public typealias Iterator = OrderedDictionaryIterator<Key,Value>
    
    internal var dict : [Key:Value]
    internal var order : [Key]
    
    public init() {
        dict=[:]
        order=[]
    }
    
    public init(_ pairs: [(Key,Value)]) {
        order=pairs.map { $0.0 }
        dict=DictFromPairs(pairs)
    }
    
    
    public var count : Int { return order.count }
    
    public subscript(_ key: Key) -> Value? {
        get { return dict[key] }
        set(value) {
            if !order.contains(key) { order.append(key) }
            dict[key]=value
        }
    }
    
    public func at(index: Int) -> Value? {
        if index<0 || index>=order.count { return nil }
        return dict[order[index]]
    }
    
    public func pairAt(index: Int) -> (Key,Value?)? {
        if index<0 || index>=order.count { return nil }
        return (order[index],dict[order[index]])
    }
    
    public func removeValue(forKey key: Key) {
        if order.contains(key) {
            dict.removeValue(forKey: key)
            let o=order.filter { $0 != key }
            order=o
        }
    }
    
    public func removeValue(forIndex idx: Int) {
        if idx >= 0 && idx < order.count {
            removeValue(forKey: order[idx])
        }
    }
    
    public func removeAll() {
        dict=[:]
        order=[]
    }
    
    public var keys : [Key] { return order }
    
    public func containsKey(_ key : Key) -> Bool {
        return order.contains(key)
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(self)
    }
    
    public var description : String {
        var out : [String]=[]
        self.forEach { (kv : (Key,Value?)) in
            out.append("\(kv.0)=\(kv.1!)")
        }
        return out.joined(separator: " ")
    }
    
    
}

public class SortedDictionary<Key : Hashable & Comparable ,Value> : OrderedDictionary<Key,Value> {
    
    public override init() {
        super.init()
    }
    
    public override init(_ pairs : [(Key,Value)]) {
        super.init(pairs)
        order.sort()
    }
    
    public init(_ d: [Key:Value]) {
        super.init( DictToPairs(d) )
        order.sort()
    }
    
    public override subscript(_ key: Key) -> Value? {
        get { return dict[key] }
        set(value) {
            if !order.contains(key) {
                order.append(key)
                order.sort(by: { $0 < $1 })
            }
            dict[key]=value
        }
    }
    
    public func update() {
        order.sort()
    }
    
}
