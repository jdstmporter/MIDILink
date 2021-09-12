//
//  AppDelegate.swift
//  MIDIUtils
//
//  Created by Julian Porter on 08/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var controller: Controller!
    
    static let FontChangedEvent=NSNotification.Name("FontChangedEventName");
    private var tableFont : NSFont!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints")
        
        // Insert code here to initialize your application
        debugPrint("Setting font")
        tableFont=Font.Table
        NSFontManager.shared.setSelectedFont(tableFont, isMultiple: false)
        NotificationCenter.default.post(name: AppDelegate.FontChangedEvent, object: nil, userInfo: ["font": tableFont as Any ])
        debugPrint("Set font")
   
        controller.scanForEndPoints()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func changeFont(_ sender: Any?) {
        let f = (sender as! NSFontManager?)?.convert(tableFont)
        if f != nil { tableFont = f! }
        NotificationCenter.default.post(name: AppDelegate.FontChangedEvent, object: nil, userInfo: ["font": tableFont as Any ])
    }
    
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool { false }
    @IBAction func applicationShouldOpenAboutPanel(_ sender: Any) { AboutPanel.launch() }
    

    


}

