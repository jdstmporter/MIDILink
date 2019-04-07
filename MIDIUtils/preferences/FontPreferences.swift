//
//  FontPreferences.swift
//  MIDIUtils
//
//  Created by Julian Porter on 01/07/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa


class FontSelector {
    
    enum FontError : Error {
        case All
    }
    
    private let manager : NSFontManager
    private let preferences : Preferences
    private var key : String!
    private var panel : NSFontPanel?
    
    init(preferences p : Preferences,key k: String) throws {
        preferences=p
        if !preferences.has(key: k) { throw FontError.All }
        key=k
        manager=NSFontManager.shared
        manager.target=self
        manager.action=#selector(FontSelector.changeFont(_:))
        
        panel=nil
    }
    
    deinit {
        panel?.close()
    }
    
    
    public func pick() throws {
        if panel == nil {
            let font = try currentFont()
            try makePanel(font)
            panel!.makeKeyAndOrderFront(nil)
        }
        else { throw FontError.All }
    }
    
    private func currentFont() throws -> NSFont {
        let font : Font? = preferences.get(key: key)
        if font==nil { throw FontError.All }
        return font!.font
    }
    
    private func makePanel(_ font : NSFont) throws  {
        manager.setSelectedFont(font, isMultiple: false)
        let p=manager.fontPanel(true)
        if p==nil { throw FontError.All }
        panel=p!
    }
            
    
    @objc private func changeFont(_ sender: Any?) {
        let selected=manager.selectedFont
        if selected != nil {
            let newFont=Font(manager.convert(selected!))
            preferences.set(key: key, value: newFont)
        }
        panel?.close()
        panel=nil
    }
    
}

