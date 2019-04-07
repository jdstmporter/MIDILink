//
//  PreferenceController.swift
//  MIDIUtils
//
//  Created by Julian Porter on 27/06/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import AppKit



public class PreferencesController : NSPanel, LaunchableItem, PreferenceListener {
    
    
    
    
    static var nibname = NSNib.Name("Preferences")
    static var lock = NSLock()
    
    let preferences : Preferences
    private var selectors : [String : FontSelector ]
    private var fonts : [String : VTextField ]
    private var colours : ColourPreferences!

    @IBOutlet weak var prettyPrint: NSButton!
    @IBOutlet weak var ignoreRT: NSButton!
    @IBOutlet weak var ignoreSysEx: NSButton!
    @IBOutlet weak var decodeSysEx: NSButton!
    @IBOutlet weak var enableActivityNotification: NSButton!
    @IBOutlet weak var decodeFont: VTextField!
    @IBOutlet weak var pFont: VTextField!
    @IBOutlet weak var colourContainer: NSView!
    @IBOutlet weak var colourContainer2: NSView!
    
    @IBOutlet weak var decoderTable : NSTableView!
    private var decoderDelegate: MIDIDecodeTable!
    private var xmlDelegate: Highlighter!
    @IBOutlet var xmlView: NSTextView!
    
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        preferences=Preferences()
        selectors=[:]
        fonts=[:]
        selectors["decodeFont"] = try? FontSelector(preferences: preferences, key: "decodeFont")
        selectors["printFont"] = try? FontSelector(preferences: preferences, key: "printFont")
        
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        preferences.addListener(self)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        fonts["decodeFont"]=decodeFont
        fonts["printFont"]=pFont
        colours=ColourPreferences(preferences, views: [colourContainer,colourContainer2])
        
        decoderDelegate=MIDIDecodeTable(table: decoderTable, withColour: false)
        decoderDelegate.link(decoder: MIDIDummyDecoder())
        preferences.addListener(decoderDelegate)
        
        xmlDelegate=Highlighter(view: xmlView)
        xmlDelegate.link(decoder: MIDIDummyDecoder())
        preferences.addListener(xmlDelegate)
        
        preferences.push()
        
        
    }
    
    
    @IBAction public func reset(_ sender: Any? = nil) {
        preferences.reset(sender)
    }
    
    public func open() {
        makeKeyAndOrderFront(nil);
    }
    
    public override func close() {
        preferences.synchronise()
        super.close()
    }
    
    @IBAction internal func booleanChanged(_ sender: Any) {
        preferences.set(key: "ignoreRT", value: ignoreRT?.boolValue)
        preferences.set(key: "ignoreSysEx", value: ignoreSysEx?.boolValue)
        preferences.set(key: "decodeSysEx", value: decodeSysEx?.boolValue)
        preferences.set(key: "enableActivity", value: enableActivityNotification?.boolValue)
        preferences.set(key: "prettyPrint", value: prettyPrint?.boolValue)
        preferences.synchronise()
    }
    
    private func change(control : NSButton?,key : String) {
        let value : Bool = preferences.get(key:key) ?? false
        if (value != control?.boolValue) { control?.boolValue=value }
    }
    
    private func updateFont(key : String,window : VTextField) {
        let decode : Font? = preferences.get(key: key)
        if decode == nil { return }
        if decode!.description == window.stringValue { return }
        DispatchQueue.main.async {
            let font=decode!.font
            window.font=font
            window.stringValue=decode!.description
            window.setBoundsSize(NSSize(width: window.bounds.width, height: window.fontHeight(font)+2))
            window.invalidateIntrinsicContentSize()
            window.needsDisplay=true
            debugPrint("\(window.bounds.size)")
        }
    }
    
    
    public func preferencesChanged(_ preference: PreferencesReader) {
        change(control: ignoreRT, key: "ignoreRT")
        change(control: ignoreSysEx, key: "ignoreSysEx")
        change(control: decodeSysEx, key: "decodeSysEx")
        change(control: enableActivityNotification, key: "enableActivity")
        decodeSysEx?.isEnabled = !(ignoreSysEx?.boolValue ?? false)
        
        fonts.forEach{ (kv) in
            let window=kv.value
            updateFont(key: kv.key,window: window)
        }
    }
    
    @IBAction func changeDecoderFont(_ sender: Any) {
        try? selectors["decoderFont"]?.pick()
    }
    
    @IBAction func changePrintFont(_ sender: Any) {
        try? selectors["printFont"]?.pick()
    }
    
    @IBAction func changeColour(_ sender: NSColorWell) {
        colours.set(tag: sender.tag, colour: sender.color)
        sender.activate(true)
    }
    
    
    public static var the : PreferencesController!
    public static func launch() {
        if the==nil { the = instance() }
        the?.open()
    }
    public static func close() {
        the?.close()
    }
    
}
