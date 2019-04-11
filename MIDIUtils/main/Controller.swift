//
//  Controller.swift
//  MIDIUtils
//
//  Created by Julian Porter on 16/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import MIDITools

class Controller : NSViewController {
    
    static let OpenLinkPanelRequest=NSNotification.Name("OpenLinkPanelRequest")
    
    @IBOutlet weak var sources: NSTableView!
    @IBOutlet weak var destinations: NSTableView!
    
    @IBOutlet weak var sDelegate: MIDIEndPointHandler!
    @IBOutlet weak var dDelegate: MIDIEndPointHandler!
    
    @IBOutlet var fontManager: NSFontManager!
    
    private var links : LinkManager!
    private var linkView : LinkageWindow!
    private var preferences : PreferencesReader!
    
    private var inj : NSWindow!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        preferences=PreferencesReader()
        preferences.addListener(sDelegate)
    }
    
    func load(sources s: [MIDIEndpoint], destinations d: [MIDIEndpoint]) {
        links=LinkManager(froms: s,tos: d)
        debugPrint("Loading data : \(s.count) sources and \(d.count) destinations")
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.showLinks(_:)), name: Controller.OpenLinkPanelRequest, object: nil)
        try? sDelegate.load(endpoints: s)
        try? dDelegate.load(endpoints: d)
        DispatchQueue.main.async {
            self.sources?.reloadData()
            self.destinations?.reloadData()
        }
        //inj=InjectionWindow.Create(endpoint: nil)
        //inj.makeKeyAndOrderFront(nil)

        
    }
    
     func scanForEndPoints() {
        debugPrint("Loading view controller")
        do {
            let m = MIDISystem.common
            m.enumerate()
            load(sources: m[.source], destinations: m[.destination])
        }
        catch {
            debugPrint("There was an error")
        }
    }
    
    @objc func showLinks(_ n: NSNotification? = nil) {
        debugPrint("Yes!")
        if linkView==nil {
            linkView=LinkageWindow.Create()
            linkView.setDevices(links)
        }
        linkView.makeKeyAndOrderFront(nil)
        linkView.touch()
    }
    @IBAction func action(_ sender: Any) {
        showLinks()
    }
    
    @IBAction func filterAction(_ sender: Any) {
        let filter : Bool = preferences.get(key: "ignoreRT") ?? true
        sDelegate.filtered(!filter)
    }
}
