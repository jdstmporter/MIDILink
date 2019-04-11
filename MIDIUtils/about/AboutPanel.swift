//
//  AboutPanel.swift
//  MIDIUtils
//
//  Created by Julian Porter on 28/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa

class AboutPanel : NSPanel, LaunchableItem {
    static let CopyrightTag = "NSHumanReadableCopyright"
    static let AppVersionTag = "CFBundleShortVersionString"
    
    static var nibname = NSNib.Name("About")
    static var lock = NSLock()
    
    @IBOutlet weak var copyright: NSTextField!
    
    private static var the : AboutPanel?
    public static func launch() {
        if the==nil {
            the = instance()
            let dict=Bundle.main.infoDictionary ?? [:]
            let copyright = (dict[CopyrightTag] as! String? ?? "Copyright Tyburn Arts Tech").trimmingCharacters(in: .whitespacesAndNewlines)
            let appVersion = (dict[AppVersionTag] as! String? ?? "1").trimmingCharacters(in: .whitespacesAndNewlines)
            the?.copyright.stringValue="MIDIUtils version \(appVersion), \(copyright)";
        }
        the?.makeKeyAndOrderFront(nil)
    }
}
