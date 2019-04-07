//
//  COlourPreferences.swift
//  MIDIUtils
//
//  Created by Julian Porter on 03/07/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

public enum Name : Int {
    case xmlElementColour = 1
    case xmlAttributeColour = 2
    case xmlHeaderColour = 3
    case xmlTextColour = 4
    case xmlAttributeTextColour = 5
    case commandColour = 6
    case channelColour = 7
    case valueColour = 8
    case textColour = 9
    case rawByteColour = 10
    
    public static let all : [Name] = [.xmlElementColour,.xmlAttributeColour,.xmlHeaderColour,.xmlTextColour,.xmlAttributeTextColour,
                                      .commandColour,.channelColour,.valueColour,.textColour,.rawByteColour]
    public init?(_ name : String) {
        let c = Name.all.filter { "\($0)" == name }.first
        if c==nil { return nil }
        self=c!
    }
    public var str : String { return "\(self)" }
}

public class ColourPreferences {
    
    
    
    private var colours : [NSColorWell]
    private var preferences : Preferences
    
    public init(_ p: Preferences,colours c : [NSColorWell]) {
        preferences=p
        colours=c
        reset()
    }
    public convenience init(_ p: Preferences, view : NSView) {
        let wells = (view.subviews.filter { $0 is NSColorWell }).map { $0 as! NSColorWell }
        self.init(p,colours: wells)
    }
    public convenience init(_ p: Preferences, views : [NSView]) {
        let wells = views.reduce([], { (result: [NSColorWell], view: NSView) in
            let w = (view.subviews.filter { $0 is NSColorWell }).map { $0 as! NSColorWell }
            return result + w
        })
        self.init(p,colours: wells)
    }
    
    
    
    private static func nameFor(_ c: NSColorWell) -> String? {
        let n=Name(rawValue : c.tag)
        if n==nil { return nil }
        return "\(n!)"
    }
    
    func reset() {
        colours.forEach { well in
            let name=ColourPreferences.nameFor(well)
            if name != nil {
                let c : Colour? = preferences.get(key: "\(name!)")
                if c != nil { well.color=c!.colour }
            }
        }
    }
    
    func get(tag: Int) -> NSColor? {
        return (colours.filter { $0.tag == tag }).first?.color
    }
    func set(tag: Int,colour: NSColor) {
        let name=Name(rawValue: tag)
        if name==nil { return }
        set(name: name!,colour: colour)
    }
    
    func set(name: Name,colour: NSColor) {
        let well=(colours.filter { $0.tag == name.rawValue }).first
        if well==nil { return }
        well!.color=colour
        preferences.set(key: "\(name)",value: Colour(colour))
    }
    
    
}

public class Colours {
    
    
    
    
    private var colours : [Name:NSColor]
    
    public init(preferences p : PreferencesReader) {
        colours=[:]
        preferencesChanged(p)
    }
    
    
    public func preferencesChanged(_ preference: PreferencesReader) {
        colours.removeAll()
        Name.all.forEach { key in
            let value : Colour? = preference.get(key: "\(key)")
            if value != nil { colours[key] = value!.colour }
        }
    }
    
    public subscript(_ key : Name) -> NSColor? { return colours[key] }
}
