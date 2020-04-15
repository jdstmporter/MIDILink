//
//  EventView.swift
//  MIDIUtils
//
//  Created by Julian Porter on 15/04/2020.
//  Copyright © 2020 JP Embedded Solutions. All rights reserved.
//
import Cocoa

class KeyedView : NSView {
    public typealias Callback = (NSEvent) -> ()
    public var modifiersChange : Callback?
    public var mouseChange : Callback?
    
    internal var modifiers = Modifiers(enabled: true)
    internal var mouse = Mouse(enabled: false)
    
    
    
    public var shiftKey : Bool { modifiers.shiftKey }
    public var controlKey : Bool { modifiers.controlKey }
    public var optionKey : Bool { modifiers.optionKey }
    public var commandKey : Bool { modifiers.commandKey }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool { true }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    override func flagsChanged(with event: NSEvent) {
        if modifiers.update(event) { modifiersChange?(event) }
        print("Option is : \(optionKey)")
        
    }
    func mouseChanged(_ event: NSEvent) {
        if mouse.update(event) { mouseChange?(event) }
    }
    override func mouseDown(with event: NSEvent) { mouseChanged(event) }
    override func mouseMoved(with event: NSEvent) { mouseChanged(event) }
    override func mouseEntered(with event: NSEvent) { mouseChanged(event) }
    override func mouseExited(with event: NSEvent) { mouseChanged(event) }
    override func mouseDragged(with event: NSEvent) { mouseChanged(event) }
    override func mouseUp(with event: NSEvent) { mouseChanged(event) }
    
    override var acceptsFirstResponder: Bool { true }
    override func becomeFirstResponder() -> Bool { true }
    
}
