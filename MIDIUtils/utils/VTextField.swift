//
//  VTextField.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa


@IBDesignable
public class VTextField : NSTextField {
    
    public enum VAlign : Int {
        case top = 1
        case middle = 0
        case bottom = -1
    }
    
    
    
    private class VTextFieldCell : NSTextFieldCell {
        
        internal var vAlign : VAlign = .middle
        private var isEditingOrSelecting : Bool = false
        internal let layoutManager : NSLayoutManager
        
        internal init(basedOn cell: NSTextFieldCell) {
            layoutManager=NSLayoutManager()
            super.init(textCell: cell.stringValue)
            drawsBackground=cell.drawsBackground
            bezelStyle=cell.bezelStyle
            backgroundColor=cell.backgroundColor
            placeholderString=cell.placeholderString
            textColor=cell.textColor
            stringValue=cell.stringValue
            alignment=cell.alignment
            font=cell.font
            isEditable=cell.isEditable
            isEnabled=cell.isEnabled
        }
        
        internal required init(coder: NSCoder) {
            layoutManager=NSLayoutManager()
            super.init(coder:coder)
        }
        
        internal override var font: NSFont? {
            get { return super.font }
            set {
                super.font=newValue
            }
        }
        
        internal var fontHeight : CGFloat {
            return (font==nil) ? 0 : font!.ascender+font!.descender+layoutManager.defaultBaselineOffset(for: font!)
        }
    
        
        internal override func drawingRect(forBounds rect: NSRect) -> NSRect {
            let def = super.drawingRect(forBounds: rect)
            //debugPrint("font height is \(fontHeight), rect height is \(rect.height)")
            switch vAlign {
            case .bottom:
                return def
            case .middle:
                let yOffset = (rect.height-fontHeight)*0.5
                if yOffset > 0 { return NSMakeRect(rect.minX, yOffset, rect.width, fontHeight) }
                return def
            case .top:
                let yOffset = rect.height-fontHeight
                if yOffset > 0 { return NSMakeRect(rect.minX, yOffset, rect.width, fontHeight) }
                return def
            }
        }
        
        internal override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
            let temp=drawingRect(forBounds: cellFrame)
            super.draw(withFrame: temp, in: controlView)
        }
        
        internal override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
            let temp=drawingRect(forBounds: rect)
            isEditingOrSelecting=true
            super.select(withFrame: temp, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
            isEditingOrSelecting=false
        }
        
        internal override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
            let temp=drawingRect(forBounds: rect)
            isEditingOrSelecting=true
            super.edit(withFrame: temp, in: controlView, editor: textObj, delegate: delegate, event: event)
            isEditingOrSelecting=false
        }
        
        
        
    }
    
    public static let defaultFont = FontDescriptor.Standard.font
    public static let defaultMonospaceFont = FontDescriptor.Monospace.font
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        cell=VTextFieldCell(basedOn: cell as! NSTextFieldCell)
        font=VTextField.defaultMonospaceFont
        verticalAlignment = .middle
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        cell=VTextFieldCell(basedOn: cell as! NSTextFieldCell)
        font=VTextField.defaultMonospaceFont
        verticalAlignment = .middle
    }
    
    convenience public init(labelWithString string: String) {
        self.init(frame: NSZeroRect)
        cell=VTextFieldCell(basedOn: cell as! NSTextFieldCell)
        font=VTextField.defaultMonospaceFont
        verticalAlignment = .middle
        self.setBackground(colour: NSColor.clear)
        self.stringValue=string
    }
    
    
    
    public var verticalAlignment : VAlign {
        get { return (cell! as! VTextFieldCell).vAlign }
        set(a) { (cell! as! VTextFieldCell).vAlign=a }
    }
    
    @IBInspectable
    public var vAlignment : Int {
        get { return verticalAlignment.rawValue }
        set(v) {
            let val=max(-1,min(1,v))
            verticalAlignment=VAlign(rawValue: val) ?? .middle
        }
    }
    
    
    
    public func useDefaultFont(_ f : FontDescriptor = .Monospace) {
            font=f.font
    }
    
    override public var font : NSFont? {
        get { return super.font }
        set(f) {
            super.font=f
            if self.cell is VTextFieldCell? { (self.cell as! VTextFieldCell?)?.font=f }
            else { (self.cell as! NSTextFieldCell?)?.font=f }
            self.needsToDraw(bounds)
        }
    }
    
    internal func fontHeight(_ font : NSFont) -> CGFloat {
        return (self.cell is VTextFieldCell?) ? (self.cell as! VTextFieldCell?)!.fontHeight : 0
    }
    internal var height : CGFloat {
        get { return bounds.height }
        set {
            setBoundsSize(NSSize(width: bounds.width, height: newValue))
        }
    }
    private var textCell : NSTextFieldCell? { return cell as! NSTextFieldCell? }
    
    
    public func setIntegerRange(minimum: Int,maximum: Int,nDigits : Int) {
        if self.formatter==nil { return}
        let f = self.formatter! as! NumberFormatter
        f.allowsFloats=false
        f.maximum=maximum as NSNumber
        f.minimum=minimum as NSNumber
        f.maximumIntegerDigits=nDigits
        self.integerValue=max(minimum,min(maximum,self.integerValue))
    }
    
    public func setBackground(colour : NSColor) {
        let c = cell as! NSTextFieldCell?
        c?.backgroundColor=colour
    }
    
    public func setForeground(colour : NSColor) {
        let c = cell as! NSTextFieldCell?
        c?.textColor=colour
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let c = cell as! NSTextFieldCell?
        if  drawsBackground && c?.backgroundColor != nil {
            c!.backgroundColor!.setFill()
            NSBezierPath(rect: dirtyRect).fill()
        }
        super.draw(dirtyRect)
    }
    
    

    
    
    
 
    
    
    
    
}


