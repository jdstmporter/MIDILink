//
//  CodingExtensions.swift
//  MIDIUtils
//
//  Created by Julian Porter on 27/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

public protocol StringRepresentable : CustomStringConvertible {
    init?(_ string : String)
}

extension Bool : StringRepresentable {}
extension String : StringRepresentable {
    public init?(_ string: String) { self=string }
}


class Colour : StringRepresentable {
    
    private let _colour : NSColor
    
    public required init?(_ string: String) {
        do {
            let parts=try Coding.split(string, to: 3)
            let spaces = NSColorSpace.availableColorSpaces(with: .unknown).filter { $0.localizedName == parts[0]}
            if spaces.count == 0 { throw Coding.CodingError.All }
            let n = try Coding.int(parts[1])
            let components = try Coding.splitCG(parts[2])
            if components.count != n { throw Coding.CodingError.All }
            _colour=NSColor(colorSpace: spaces[0], components: components, count: n)
        }
        catch {
            return nil
        }
    }
    
    public init(_ c : NSColor) { _colour=c }
    public var colour : NSColor { return _colour }
    public var description: String { return String(colour: _colour)! }
}

class Font : StringRepresentable {
    
    private var _font : NSFont
    
    public init(_ descriptor: FontDescriptor) { _font=descriptor.font }
    public init(_ f : NSFont) { _font=f }
    
    public required init?(_ string: String) {
        do {
            let parts=try Coding.split(string)
            switch parts.count {
            case 2:     // NSFont
                let size = try Coding.cgfloat(parts[1])
                _font = NSFont(name: parts[0], size: size)!
                break
            case 3:
                let size = try Coding.cgfloat(parts[0])
                let weight = try Coding.cgfloat(parts[1])
                let family = FontDescriptor.Families(rawValue: try Coding.int(parts[2]))
                if family==nil { throw Coding.CodingError.All }
                let fd = FontDescriptor(family!,size,NSFont.Weight(rawValue: weight))
                _font = fd.font
                break
            default:
                throw Coding.CodingError.All
            }
        }
        catch {
            return nil
        }
        
    }
    public var font : NSFont { return _font }
    public var description: String { return String(font: _font)! }
}

extension String {
    
    init?(colour: NSColor) {
        let n=colour.numberOfComponents
        var components = [CGFloat].init(repeating: 0.0, count: n)
        colour.getComponents(&components)
        let c=components.map { "\($0)" } .joined(separator:",")
        
        let space=colour.colorSpace.localizedName ?? ""
        self.init("\(space):\(n):\(c)")
    }
    
    init?(font: FontDescriptor) {
        self.init(font.description)
    }
    
    init?(font: NSFont) {
        self.init("\(font.fontName):\(font.pointSize)")
    }
    
}

