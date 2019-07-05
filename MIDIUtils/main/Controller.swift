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
    
    private var links = LinkedEndpoints()
    
    
    
    private var inj : NSWindow!
    
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        links.reset()
    }
    
    
    
     func scanForEndPoints() {
        debugPrint("Loading view controller")
        reloadAction(nil)
    }
    
    @IBAction func linkAction(_ sender: Any) {
        if let from=sDelegate.selected, let to=dDelegate.selected {
            if links.linked(from.uid, to.uid) {
                try? links.remove(from: from, to: to)
            }
            else if !links.linked(from: from.uid) && !links.linked(to: to.uid) {
                try? links.create(from: from, to: to)
            }
            DispatchQueue.main.async {
                self.sources?.reloadData()
                self.destinations?.reloadData()
            }
        }
    }
    
    
    @IBAction func reloadAction(_ sender: Any!) {
        do {
            let m = try MIDISystem()
            m.endpoints.forEach { debugPrint($0.description) }
            links.reset(m.endpoints.map { $0.uid })
            try sDelegate.load(endpoints: m.sources, links: links)
            try dDelegate.load(endpoints: m.destinations, links: links)
            DispatchQueue.main.async {
                self.sources?.reloadData()
                self.destinations?.reloadData()
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
