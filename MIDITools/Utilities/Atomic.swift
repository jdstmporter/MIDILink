//
//  Atomic.swift
//  MIDIUtils
//
//  Created by Julian Porter on 05/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Foundation

public class Atomic<T> {
    
    private let uid : String
    private var queue : DispatchQueue
    private var _value : T
        
    public init(_ v : T) {
        uid = UUID().uuidString
        queue=DispatchQueue(label: uid)
        _value = v
    }
    
    public var value : T {
        get {
            return queue.sync { return _value }
        }
        set(v) {
            queue.sync { _value = v }
        }
    }
    
    internal func update(action : (T) -> T) -> T {
        return queue.sync {
            _value = action(_value)
            return _value
        }
    }
    
}

public class FIFO<T> {
    private let uid : String
    private var queue : DispatchQueue
    private var _fifo : [T]
    
    public init() {
        uid = UUID().uuidString
        queue=DispatchQueue(label: uid)
        _fifo=[]
    }
    
    public func push(value : T) {
        queue.sync { _fifo.insert(value, at: 0) }
    }
    
    public func pop() -> T? {
        return queue.sync { return _fifo.popLast() }
    }
    
    public var isEmpty : Bool {
        return queue.sync { return _fifo.isEmpty }
    }
    
    public var count : Int {
        return queue.sync { return _fifo.count }
    }
    
    public func clear() {
        queue.sync { _fifo.removeAll() }
    }
    
    public var all : [T] {
        return queue.sync {
            let out=_fifo
            _fifo.removeAll()
            return out
        }
    }
}

public class AtomicBoolean : Atomic<Bool> {
    
    public init() {
        super.init(false)
    }
    
    override public init(_ b : Bool) {
        super.init(b)
    }
    
    public var isSet : Bool {
        return value
    }
    
}

public class AtomicInteger : Atomic<Int> {
    
    public init() {
        super.init(0)
    }
    
    override public init(_ i : Int) {
        super.init(i)
    }
    
    public func increment() -> Int {
        return update(action: { $0 + 1 } )
    }
    
    public func decrement() -> Int {
        return update(action: { $0 - 1 } )
    }
}
