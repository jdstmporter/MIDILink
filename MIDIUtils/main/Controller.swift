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
    
    
    private var inj : NSWindow!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(Controller.showLinks(_:)), name: Controller.OpenLinkPanelRequest, object: nil)
        
    }
    
    
    
     func scanForEndPoints() {
        debugPrint("Loading view controller")
        if self.links==nil { self.links = LinkManager() }
        reloadAction(nil)
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
    
    @IBAction func reloadAction(_ sender: Any!) {
        do {
            let m = try MIDISystem()
            m.endpoints.forEach { debugPrint($0.description) }
            try sDelegate.load(endpoints: m.sources)
            try dDelegate.load(endpoints: m.destinations)
            DispatchQueue.main.async {
                self.sources?.reloadData()
                self.destinations?.reloadData()
                
                self.links.load(from: m.sources, to: m.destinations)
                self.linkView?.table.reloadData()
            }
            
        }
        catch let e {
            print("Error was \(e)")
        }
    }
    
    
    @IBAction func filterAction(_ sender: Any) {
        let filter : Bool =  true
        sDelegate.filtered(!filter)
    }
}
