//
//  Fonts.swift
//  MIDIUtils
//
//  Created by Julian Porter on 21/04/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

public struct FontDescriptor : Codable, CustomStringConvertible {

    public enum Sizes {
        case Normal
        case Medium
        case Small
    }

    public enum Families : Int {
        case Monospace = 0
        case Standard = 1
        case Table = 2
    }
    
    public var size : CGFloat = 0
    public var weight: NSFont.Weight = .regular
    public let family : Families
    
    private var sizes : [FontDescriptor.Sizes: CGFloat] = [:]
    
    init(_ f: Families = .Standard, _ s : CGFloat = 0,_ w: NSFont.Weight = .regular) {
        family=f
        size=s
        weight=w
    }
    
    init(family f: Families, size s: Sizes = .Normal, weight w: NSFont.Weight = .regular) {
        sizes   = [ .Small: 10, .Medium: NSFont.smallSystemFontSize, .Normal: NSFont.systemFontSize ]

        family = f
        size=sizes[s] ?? 0
        weight=w
    }
    
    
    init(monospaceOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Monospace)
        size = sizes[s] ?? 0
        weight = b ? .bold : .regular
    }
    
    init(standardOfSize s: Sizes, isBold b: Bool = false) {
        self.init(family: .Standard)
        size = sizes[s] ?? 0
        weight = b ? .bold : .regular
    }
    
    init(standardWithTextSize s: CGFloat, isBold b: Bool = false) {
        self.init(family: .Standard)
        size = s
        weight = b ? .bold : .regular
    }
    
    public var font : NSFont {
        switch family {
        case .Standard:
            return NSFont.systemFont(ofSize: size, weight: weight)
        case .Monospace:
            return NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        case .Table:
            return NSFont(name: "CourierNewPSMT", size: size)!
        }
    }
    
    enum CodingKeys : String, CodingKey {
        case size
        case weight
        case family
    }
    
    public init(from decoder: Decoder) throws {
        let container=try decoder.container(keyedBy: CodingKeys.self)
        size=CGFloat(try container.decode(Double.self,forKey: .size))
        weight=NSFont.Weight(rawValue: CGFloat(try container.decode(Double.self,forKey: .weight)))
        family = Families(rawValue: try container.decode(Int.self,forKey: .family)) ?? .Standard
    }
    
    public func encode(to encoder: Encoder) throws {
        var container=encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Double(size), forKey: .size)
        try container.encode(Double(weight.rawValue), forKey: .weight)
        try container.encode(family.rawValue, forKey: .family)
    }
    
    public var description : String {
        return "\(size):\(weight.rawValue):\(family.rawValue)"
    }
    
    public init?(from string: String?) {
        if string == nil { return nil }
        let parts=string!.split(separator: ":").map { Double(String($0)) }
        if parts.count != 3 { return nil }
        if parts[0] != nil { size=CGFloat(parts[0]!)} else { return nil }
        if parts[1] != nil { weight=NSFont.Weight(rawValue: CGFloat(parts[1]!))} else { return nil }
        if parts[2] != nil { family=Families(rawValue: Int(parts[2]!)) ?? .Standard } else { return nil }
    }
    
    public static let Monospace=FontDescriptor(monospaceOfSize: .Normal)
    public static let MonospaceSmall=FontDescriptor(monospaceOfSize: .Small)
    public static let Standard=FontDescriptor(standardOfSize: .Normal)
    public static let Small=FontDescriptor(standardOfSize: .Small)
    public static let Table=FontDescriptor(.Table)
}




