//
//  Extensions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 05/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

public class FormattedString {
    private static let defaultFont = FontDescriptor.Small.font
    private static let defaultColour = NSColor.black
    private static let underline=NSUnderlineStyle.single.rawValue | NSUnderlineStyle.byWord.rawValue
    private static let nounderline=NSUnderlineStyle().rawValue
    
    private var string : NSMutableAttributedString
    private let baseFont : NSFont
    private let baseColour : NSColor
    
    private var attributes : [NSAttributedString.Key:Any] = [:]
    
    public init(font f: NSFont? = nil, colour c: NSColor? = nil) {
        
        baseFont = f ?? FormattedString.defaultFont
        baseColour = c ?? FormattedString.defaultColour
        
        string=NSMutableAttributedString()

        attributes[.foregroundColor]=baseColour
        attributes[.font]=baseFont
        attributes[.underlineStyle]=FormattedString.nounderline
    }
    
    public var Font : NSFont? {
        get { return attributes[.font] as! NSFont? }
        set { attributes[.font] = newValue ?? baseFont }
    }
    
    public var Colour : NSColor? {
        get { return attributes[.foregroundColor] as! NSColor? }
        set { attributes[.foregroundColor] = newValue ?? baseColour }
    }
    
    public var Underline : Bool {
        get { return (attributes[.underlineStyle]! as! Int) != FormattedString.nounderline }
        set { attributes[.underlineStyle] = (newValue) ? FormattedString.underline : FormattedString.nounderline }
    }
    
    public func append(_ s: String, colour c: NSColor? = nil) {
        let old = Colour
        if c != nil { Colour=c! }
        string.append(NSAttributedString(string: s, attributes: attributes))
        Colour = old
    }
    
    public var Value : NSAttributedString { return string }
}
