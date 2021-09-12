//
//  File.swift
//  MIDIUtils
//
//  Created by Julian Porter on 21/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa


internal extension NSProgressIndicator {
    
    var range : Double {maxValue-minValue}
    
    var proportion : Double {
        get {  (doubleValue-minValue)/range }
        set(p) { doubleValue=minValue+p*range }
    }
    
    func clear() {doubleValue=minValue}
    
    func start() {
        clear()
        isHidden=false
        startAnimation(nil)
    }
    
    func stop() {
        stopAnimation(nil)
        isHidden=true
        clear()
    }
}

internal extension NSView {
    
    @IBInspectable var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {return nil}
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
    
    func flash(duration : Float = 0.1, colour: NSColor = NSColor.black, callback : (() -> ())? = nil) {
        let group=DispatchGroup()
        flash(group,duration: duration, colour: colour)
        group.notify(queue: DispatchQueue.main, execute: {
            callback?()
        })
    }
    
    func flash(_ group : DispatchGroup,duration : Float = 0.1, colour: NSColor = NSColor.black) {
        let b = backgroundColor
        group.enter()
        DispatchQueue.main.async {
            self.backgroundColor=colour
            group.leave()
        }
        group.enter()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(fromNowInSeconds: duration), execute: {
            self.backgroundColor=b
            group.leave()
        })

    }
}

internal extension NSControl {
    var foregroundColor: NSColor? {
        get {
            if self is NSTextField {return (self as! NSTextField).textColor}
            else {return nil}
        }
        set {
            if self is NSTextField { (self as! NSTextField).textColor=newValue }
        }
    }
}

internal extension NSTableView {
    
    func reuse<T>(tag: NSUserInterfaceItemIdentifier, owner: Any?) -> T? {
         makeView(withIdentifier: tag, owner: owner) as! T?
    }
}

internal extension NSPopUpButton {
    
    func initialiseItems(from values: [String]) {
        self.removeAllItems()
        values.forEach { self.addItem(withTitle: $0) }
        //keys.enumerated().forEach { self.item(at: $0.offset)!.tag = Int($0.element) }
        
        self.selectItem(at: 0)
        self.synchronizeTitleAndSelectedItem()
    }
}


internal extension NSStepper {
    
    func setIntegerRange(minimum: Int,maximum: Int) {
        self.maxValue=Double(maximum)
        self.minValue=Double(minimum)
        self.integerValue=max(minimum,min(maximum,self.integerValue))
    }
}



internal extension NSButton {
    
    var boolValue : Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }

}

internal extension NSImage {
    var cgImage: CGImage? {
        cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
}

internal extension NumberFormatter {
    
    struct Model : OptionSet {
        let rawValue : Int
        
        init(rawValue rv: Int) {rawValue=rv}
        
        
        static let Integer = Model(rawValue: 1<<0)
        static let Float = Model(rawValue: 1<<1)
        static let Exponent = Model(rawValue: 1<<2)
        static let Positive = Model(rawValue: 1<<3)
        
        static let Scientific : Model = [.Float,.Exponent]
    }
    
    convenience init(model: Model,dp : Int = 0) {
        self.init()
        if model.contains(.Integer) {
            allowsFloats=false
            roundingMode = .floor
            numberStyle = .none
            maximumFractionDigits=0
        }
        if model.contains(.Float) {
            allowsFloats=true
            numberStyle = .decimal
            maximumFractionDigits=dp
        }
        if model.contains(.Exponent) {
            numberStyle = .scientific
        }
        let isFloat=model.contains(.Float)
        allowsFloats=isFloat
        
        usesSignificantDigits=false
        usesGroupingSeparator = false
        if model.contains(.Positive) { minimum=0 }
    }
    
}


