//
//  Modifiers.swift
//  MIDIUtils
//
//  Created by Julian Porter on 14/04/2020.
//  Copyright © 2020 JP Embedded Solutions. All rights reserved.
//

import Cocoa

public protocol EventHandler {
    associatedtype Status
    
    init(enabled : Bool)
    
    var enabled : Bool { get set }
    var status : Status { get }
    subscript(_ : Status) -> Bool { get }
    
    @discardableResult mutating func update(_ : NSEvent) -> Bool
    mutating func reset()
    
    static func isRelevant(_ : NSEvent) -> Bool
}


public struct Modifiers : EventHandler {
    public typealias Flags = NSEvent.ModifierFlags
    private static let NULL = Flags(rawValue: 0)
    
    public private(set) var status : Flags = Modifiers.NULL
    public var enabled : Bool
    
    public init(enabled : Bool) { self.enabled = enabled }
    
    public subscript(_ mask : Flags) -> Bool { mask.isSubset(of: status) }
    public static func isRelevant(_ event: NSEvent) -> Bool { event.type == .flagsChanged }
    
    @discardableResult public mutating func update(_ event: NSEvent) -> Bool {
        guard enabled, Modifiers.isRelevant(event) else { return false }
        
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let delta = flags.symmetricDifference(status)
        status = flags
        return !delta.isEmpty
    }
    public mutating func reset() { status=Modifiers.NULL }
    
    public var shiftKey : Bool { status.contains(.shift) }
    public var controlKey : Bool { status.contains(.control) }
    public var optionKey : Bool { status.contains(.option) }
    public var commandKey : Bool { status.contains(.command) }
}
