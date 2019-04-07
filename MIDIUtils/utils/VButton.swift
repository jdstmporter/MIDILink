//
//  VButton.swift
//  MIDIUtils
//
//  Created by Julian Porter on 05/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

@IBDesignable
public class VButton : NSButton {
    
    public enum VAlign : Int {
        case top = 1
        case middle = 0
        case bottom = -1
    }
    
    public enum HAlign : Int {
        case right = 1
        case middle = 0
        case left = -1
    }
    
    typealias Alignment = (h : HAlign, v: VAlign)

    
    private class VButtonCell : NSButtonCell {
        
        internal var titleAlignment : Alignment?
        internal var imageAlignment : Alignment?
        internal var hAlign : HAlign = .middle
        private var isEditingOrSelecting : Bool = false
        private let layoutManager : NSLayoutManager
        internal var foregroundColor : NSColor = NSColor.black
        
        internal init(basedOn cell: NSButtonCell) {
            layoutManager=NSLayoutManager()
            super.init(textCell: cell.stringValue)
            bezelStyle=cell.bezelStyle
            backgroundColor=cell.backgroundColor
            foregroundColor=(cell is VButtonCell) ? (cell as! VButtonCell).foregroundColor : NSColor.black
            alignment=cell.alignment
            font=cell.font
            isEditable=cell.isEditable
            isEnabled=cell.isEnabled
            title=cell.title
            alternateTitle=cell.alternateTitle
            imagePosition=cell.imagePosition
            image=cell.image
        }
        
        internal required init(coder: NSCoder) {
            layoutManager=NSLayoutManager()
            super.init(coder:coder)
        }
        
        override var imagePosition : NSControl.ImagePosition {
            get { return super.imagePosition }
            set {
                super.imagePosition=newValue
                switch newValue {
                case .imageLeft, .imageLeading:
                    titleAlignment = (h: .right,v: .middle)
                    imageAlignment = (h: .left,v: .middle)
                    break
                case .imageRight, .imageTrailing:
                    titleAlignment = (h: .left,v: .middle)
                    imageAlignment = (h: .right,v: .middle)
                    break
                case .imageOnly:
                    titleAlignment = nil
                    imageAlignment = (h: .middle,v: .middle)
                    break
                case .noImage:
                    titleAlignment = (h: .middle,v: .middle)
                    imageAlignment = nil
                    break
                default:
                    break
                }
            }
        }
        
    
        internal override func drawingRect(forBounds rect: NSRect) -> NSRect {
            let def = super.drawingRect(forBounds: rect)
            //debugPrint("Drawing rectangle : initial is \(rect)")
            return def
        }
        
        internal func imageFrame(forBounds rect: NSRect) -> NSRect {
            
            if imageAlignment==nil { return rect }
            let size = (image==nil) ? NSZeroSize : image!.size
            let scale = Swift.min(rect.height/size.height,1.0)
            
            let height=Swift.max(size.height*scale-2.0,2.0)
            let y = rect.origin.y+(rect.height-height)*0.5
            let width=size.width*height/size.height
            
            var x : CGFloat = 0
            switch imageAlignment!.h {
            case .left:
                x=rect.origin.x
                break
            case .right:
                x=rect.origin.x+rect.width-width
                break
            case .middle:
                x=rect.origin.x+0.5*(rect.height-height)
                break
            }

            let out=NSMakeRect(x, y, width, height)
            debugPrint("IMAGE Align \(imageAlignment!) : Initial \(rect) : out \(out)")
            return out

        }
        
        
        internal override func titleRect(forBounds rect: NSRect) -> NSRect {
            if titleAlignment==nil { return rect }
            let fontHeight = (font==nil) ? 0 : layoutManager.defaultLineHeight(for: font!)
            let factor : CGFloat = imageAlignment==nil ? 1.0 : 0.8
            
            let x,y,width,height : CGFloat
            switch titleAlignment!.h {
            case .left:
                x=rect.origin.x
                width=rect.width*factor
                break
            case .right:
                x=rect.width*(1.0-factor)
                width=rect.width*factor
                break
            case .middle:
                x=rect.origin.x
                width=rect.width
                break
            }
            
            switch titleAlignment!.v {
            case .bottom:
                y=rect.origin.y
                height=rect.height
            case .middle:
                y=(rect.height-fontHeight)*0.5
                height = y > 0 ? fontHeight : rect.height
                break
            case .top:
                y = rect.height-fontHeight
                height = y > 0 ? fontHeight : rect.height
                break
            }
            let out=NSMakeRect(x, y, width, height)
            debugPrint("TEXT Align \(titleAlignment!) : Initial \(rect) : out \(out)")
            return out
        }
        
        
        internal override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
            //let temp=drawingRect(forBounds: cellFrame)
            super.draw(withFrame: cellFrame, in: controlView)
        }
        
        internal override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
            debugPrint("Draw image \(image)")
            let newFrame=imageFrame(forBounds: frame)
            super.drawImage(image,withFrame: newFrame,in: controlView)
        }
        
        override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
            //let temp=titleRect(forBounds: frame)

            let m=NSMutableAttributedString(attributedString: title)
            m.addAttribute(NSAttributedString.Key.foregroundColor, value: foregroundColor, range: NSRange.init(location: 0, length: m.length))
            return super.drawTitle(m, withFrame: frame, in: controlView)
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
        cell=VButtonCell(basedOn: cell as! NSButtonCell)
        if font==nil { font=VButton.defaultMonospaceFont }
        
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        cell=VButtonCell(basedOn: cell as! NSButtonCell)
        if font==nil { font=VButton.defaultMonospaceFont }
        
    }
    
    
    
    
 
 
    
    
    
    public func useDefaultFont(_ f : FontDescriptor = .Monospace) {
        font=f.font
    }
    
    override public var font : NSFont? {
        get { return super.font }
        set(f) {
            super.font=f
            if self.cell is VButtonCell? { (self.cell as! VButtonCell?)?.font=f }
            else { (self.cell as! NSButtonCell?)?.font=f }
        }
    }
    
    private var buttonCell : VButtonCell? { return cell as! VButtonCell? }
    
    
    
    public func setBackground(colour : NSColor) {
        let c = cell as! VButtonCell?
        c?.backgroundColor=colour
    }
    
    @IBInspectable
    public var foreground : NSColor? {
        get {
            let c = cell as! VButtonCell?
            return c?.foregroundColor
        }
        set {
            let c = cell as! VButtonCell?
            c?.foregroundColor=newValue ?? NSColor.black
        }
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let c = cell as! VButtonCell?
        if  c?.backgroundColor != nil {
            c!.backgroundColor!.setFill()
            NSBezierPath(rect: bounds).fill()
        }
        super.draw(dirtyRect)
    }
    
    
    
    
    
    
    
    
    
    
    
}
