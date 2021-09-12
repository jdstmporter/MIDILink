//
//  Fonts.swift
//  MIDIUtils
//
//  Created by Julian Porter on 21/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

extension NSFont.Weight {
    public init(bold : Bool) {
        self = bold ? .bold : .regular
    }
    
}

public struct Font  {

    public enum Sizes {
        case Normal
        case Medium
        case Small
        
        internal static let sizes : [Sizes: CGFloat] = [ .Small: 10, .Medium: NSFont.smallSystemFontSize, .Normal: NSFont.systemFontSize ]
        public var size : CGFloat { return Sizes.sizes[self] ?? 0 }
    }

    public enum Families {
        public typealias Maker = (CGFloat,NSFont.Weight) -> NSFont
        
        case Monospace
        case Standard
        case Table
        
        public var maker : Maker {
            switch self {
            case .Table:
                return { (s,w) in NSFont(name: "CourierNewPSMT", size: s) ?? NSFont.systemFont(ofSize: s, weight: w) }
            case .Standard:
                return { (s,w) in NSFont.systemFont(ofSize: s, weight: w) }
            case .Monospace:
                return { (s,w) in NSFont.monospacedDigitSystemFont(ofSize: s, weight: w) }
            }
        }
        
    }
    
    public let font : NSFont
    
    public init(_ family: Families = .Standard, _ size : CGFloat = 0,_ weight: NSFont.Weight = .regular) {
        font = family.maker(size,weight)
    }
    
    public init(family f: Families, size s: Sizes = .Normal, weight w: NSFont.Weight = .regular) {
        self.init(f,s.size,w)
    }
    public init(family f: Families, size s: Sizes = .Normal, bold: Bool = false) {
        self.init(f,s.size,NSFont.Weight(bold: bold))
    }
    
    public init(monospaceOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Monospace,size: s, bold: b)
    }
    
    public init(standardOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Standard,size: s, bold: b)
    }
    
    public static let Monospace=Font(monospaceOfSize: .Normal).font
    public static let MonospaceSmall=Font(monospaceOfSize: .Small).font
    public static let Standard=Font(standardOfSize: .Normal).font
    public static let Small=Font(standardOfSize: .Small).font
    public static let Table=Font(.Table).font
}




