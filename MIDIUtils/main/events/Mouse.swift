//
//  Mouse.swift
//  MIDIUtils
//
//  Created by Julian Porter on 14/04/2020.
//  Copyright © 2020 JP Embedded Solutions. All rights reserved.
//

import Cocoa

private typealias E=NSEvent.EventType
private typealias EM=NSEvent.EventTypeMask
private func _M(_ event : E) -> EM { EM(type: event) }

public struct Mouse : EventHandler  {
    
    private static let MOUSE_EVENTS : EM = [ .leftMouseDown, .rightMouseDown, .leftMouseUp, .rightMouseUp,
                                             .mouseMoved, .leftMouseDragged, .rightMouseDragged,
                                             .mouseEntered, .mouseEntered ]
    private static let LEFT_ON : EM = [ .leftMouseDown, .leftMouseDragged ]
    private static let RIGHT_ON : EM = [ .rightMouseDown, .rightMouseDragged ]
    private static let MOVING_ON : EM = [ .mouseMoved, .leftMouseDragged, .rightMouseDragged ]
    private static let LEFT_OFF : EM = .leftMouseUp
    private static let RIGHT_OFF : EM = .rightMouseUp
    private static let MOVING_OFF : EM = [ .leftMouseDown, .rightMouseDown, .leftMouseUp, .rightMouseUp ]
    
    public struct M : OptionSet {
        public var rawValue: Int
        
        static let LEFT = M(rawValue: 1)
        static let RIGHT =  M(rawValue: 2)
        static let MOVING = M(rawValue: 4)
        static let OVER = M(rawValue: 8)
        
        static let DOWN : M = [.LEFT,.RIGHT]
        
        public init() { self.rawValue = 0 }
        public init(rawValue: Int) { self.rawValue=rawValue }
    }
    public var enabled : Bool
    public private(set) var status = M()
    public var position : NSPoint?
    
    public init(enabled : Bool) { self.enabled=enabled }
    public subscript(_ mask : M) -> Bool { mask.isSubset(of: status) }
    public static func isRelevant(_ event : NSEvent) -> Bool { Mouse.MOUSE_EVENTS.contains(_M(event.type)) }
    
    @discardableResult public mutating func update(_ event : NSEvent) -> Bool {
        guard enabled, Mouse.isRelevant(event) else { return false }
        let _state = status
        let t=event.type
        if Mouse.LEFT_ON.contains(_M(t)) { status.insert(.LEFT) }
        if Mouse.RIGHT_ON.contains(_M(t)) { status.insert(.RIGHT) }
        if Mouse.MOVING_ON.contains(_M(t)) { status.insert(.MOVING) }
        
        if Mouse.LEFT_OFF.contains(_M(t)) { status.remove(.LEFT) }
        if Mouse.RIGHT_OFF.contains(_M(t)) { status.remove(.RIGHT) }
        if Mouse.MOVING_OFF.contains(_M(t)) { status.remove(.MOVING) }
        
        if t == .mouseEntered { status = .OVER }
        if t == .mouseExited { reset() }
        
        if status.contains(.OVER) { position = event.locationInWindow }
        else { position = nil }
        return status != _state
    }
    public mutating func reset() { status = M() }
    
    func normalised(in view: NSView) -> NSPoint? {
        guard let pos = position else { return nil }
        let point  = view.convert(pos, from: nil)
        guard view.bounds.contains(CGPoint(x: point.x,y: point.y)) else { return nil }
        return point
    }
    
    public var up : Bool { status.intersection(.DOWN).isEmpty }
    public var down : Bool { !status.intersection(.DOWN).isEmpty }
    
    public var move : Bool { up && status.contains(.MOVING) }
    public var drag : Bool { down && status.contains(.MOVING) }
    public var over : Bool { status.contains(.OVER) }
    
}
