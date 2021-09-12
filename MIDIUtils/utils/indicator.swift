//
//  indicator.swift
//  MIDIUtils
//
//  Created by Julian Porter on 04/07/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//
import Cocoa

class MIDIIndicatorView : NSView {
    static let ON_COLOUR : NSColor = .green
    public var status : Bool=false { didSet { self.needsDisplay=true } }
    
    
    init(status s: Bool = false) {
        super.init(frame: NSZeroRect)
        initialise(status: status)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise(status: false)
    }
    
    private func initialise(status s: Bool) {
        self.backgroundColor = .clear
        status=s
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        bounds.fill()
        
        if status {
            MIDIIndicatorView.ON_COLOUR.setFill()
            let size=bounds.size
            let scale = Swift.max(1,Swift.min(size.width,size.height)-4)
            let offsetX = (size.width-scale)/2
            let offsetY = (size.height-scale)/2
            NSBezierPath(ovalIn: NSRect(x: offsetX, y: offsetY, width: scale, height: scale)).fill()
        }
    }
    
    
    
}

