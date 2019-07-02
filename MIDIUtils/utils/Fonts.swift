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

public struct FontDescriptor  {

    public enum Sizes {
        case Normal
        case Medium
        case Small
        
        internal static let sizes : [Sizes: CGFloat] = [ .Small: 10, .Medium: NSFont.smallSystemFontSize, .Normal: NSFont.systemFontSize ]
        public var size : CGFloat { return Sizes.sizes[self] ?? 0 }
    }

    public enum Families {
        case Monospace
        case Standard
        case Table
    }
    
    public var size : CGFloat = 0
    public var weight: NSFont.Weight = .regular
    public let family : Families
    
    init(_ f: Families = .Standard, _ s : CGFloat = 0,_ w: NSFont.Weight = .regular) {
        family=f
        size=s
        weight=w
    }
    
    init(family f: Families, size s: Sizes = .Normal, weight w: NSFont.Weight = .regular) {
        self.init(f,s.size,w)
    }
    init(family f: Families, size s: Sizes = .Normal, bold: Bool = false) {
        self.init(f,s.size,NSFont.Weight(bold: bold))
    }
    
    init(monospaceOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Monospace,size: s, bold: b)
    }
    
    init(standardOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Standard,size: s, bold: b)
    }
    
    public var font : NSFont {
        switch family {
        case .Standard:
            return NSFont.systemFont(ofSize: size, weight: weight)
        case .Monospace:
            return NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        case .Table:
            return NSFont(name: "CourierNewPSMT", size: size) ?? NSFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    
   
    
    public static let Monospace=FontDescriptor(monospaceOfSize: .Normal)
    public static let MonospaceSmall=FontDescriptor(monospaceOfSize: .Small)
    public static let Standard=FontDescriptor(standardOfSize: .Normal)
    public static let Small=FontDescriptor(standardOfSize: .Small)
    public static let Table=FontDescriptor(.Table)
}




