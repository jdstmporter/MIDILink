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
    
   
    
    @IBOutlet weak var sources: NSTableView!
    @IBOutlet weak var destinations: NSTableView!
    
    @IBOutlet weak var linkButton: NSButton!
    
    
    @IBOutlet weak var sDelegate: MIDIEndPointHandler!
    @IBOutlet weak var dDelegate: MIDIEndPointHandler!
    
    @IBOutlet var fontManager: NSFontManager!
    
    private var links = LinkedEndpoints()
    
    
    
    private var inj : NSWindow!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        links.reset()
        fixButton()
    }
    
    
    
     func scanForEndPoints() {
        debugPrint("Loading view controller")
        reloadAction(nil)
    }
    
    @IBAction func clickedAction(_ sender : Any) {
        if let t = sender as? NSTableView {
            if t == sources { sDelegate.rowSelected(t) }
            if t == destinations { dDelegate.rowSelected(t) }
        }
        self.fixButton()
        
    }
    
    private func fixButton() {
        var text : String? = nil
        let from = sDelegate.selected?.uid
        let to = dDelegate.selected?.uid
        
 
        let anyLinked = links.linked(from: from) || links.linked(to: to)
        
        let fromClicked = from != nil
        let toClicked = to != nil
        
        // Rules:
        // Link iff both clicked but not linked
        // both clicked, linked to each other => unlink
        // from clicked, to not clicked, from linked, not to to => unlink
        // to clicked, from not clicked, to linked, not to from => unlink
        
        switch (fromClicked,toClicked) {
        case (true,true) :
            if links.linked(from, to) { text="Unlink" }
            else { text = anyLinked ? nil : "Link" }
        case (true,false), (false,true) :
            text = anyLinked ? "Unlink" : nil
        case (false,false) :
            text=nil
        }
        
        DispatchQueue.main.async {
            self.linkButton.title=text ?? ""
            self.linkButton.isEnabled = text != nil
        }
        
    }
    
    @IBAction func linkAction(_ sender: Any) {
        do {
            if let from=sDelegate.selected, let to=dDelegate.selected {
                if links.linked(from.uid, to.uid) {
                    try links.remove(from: from, to: to)
                }
                else if !links.linked(from: from.uid) && !links.linked(to: to.uid) {
                    try links.create(from: from, to: to)
                }
            }
            else if let from=sDelegate.selected {
                try links.remove(from: from.uid)
            }
            else if let to=dDelegate.selected {
                try links.remove(to: to.uid)
            }
            
            try self.sDelegate.load(links: links)
            try self.dDelegate.load(links: links)
            
            
            
            DispatchQueue.main.async {
                self.sources?.reloadData()
                self.destinations?.reloadData()
            }
            
            self.fixButton()
        }
        catch let e {
            print("Error when linking: \(e)")
        
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
