//
//  Atomic.swift
//  MIDIManager
//
//  Created by Julian Porter on 07/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation

internal class Atomic<T> {
    private var val : T
    
    public init(_ value : T) { val = value }
    public var value : T { return DispatchQueue.global().sync { return self.val } }
    public func set(_ value : T) { DispatchQueue.global().sync { self.val = value } }
    
    public func test(_ predicate : (T) -> Bool) -> Bool { return DispatchQueue.global().sync { return predicate(self.val) } }
    public func apply(_ function : (T) -> T) -> T {
        return DispatchQueue.global().sync {
            self.val = function(self.val)
            return self.val
        }
    }
}

internal class AtomicInteger<T> : Atomic<T> where T  : FixedWidthInteger {
    
    public init() { super.init(0) }
    
    @discardableResult public func inc() -> T { return apply({ $0 + 1 }) }
    public static func==(_ l : AtomicInteger<T>,r : T) -> Bool { return l.test({ $0==r })}
    public static func==(_ l : T,_ r : AtomicInteger<T>) -> Bool { return r.test({ $0==l })}
    
    public static var zero : AtomicInteger<T> { return AtomicInteger<T>() }
}

internal class AtomicBoolean : Atomic<Bool> {
    
    public static let True = AtomicBoolean(true)
    public static let False = AtomicBoolean(false)
    
}
