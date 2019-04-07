//
//  EndPointDelegate.swift
//  MIDIUtils
//
//  Created by Julian Porter on 19/02/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreMIDI
import MIDITools


public class MIDIEndPointHandler : NSObject, NSTableViewDataSource, NSTableViewDelegate, PreferenceListener {
    
    
    
    enum Column {
        case Text
        case UID
        case Action
        case Switch
    }
    
    internal var registered : OrderedDictionary<MIDIUniqueID,MIDIEndPointWrapper>
    @IBOutlet weak var table : NSTableView!
    private var enableActivityIndicators : Bool = true
    internal var cells : OrderedDictionary<MIDIUniqueID,RowCellSet>
    
    public override init() {
        registered=OrderedDictionary<MIDIUniqueID,MIDIEndPointWrapper>()
        cells = OrderedDictionary<MIDIUniqueID,RowCellSet>()
        super.init()
        
        
        NotificationCenter.default.addObserver(forName: MIDIListener.MIDIListenerEventNotification, object: nil, queue: nil, using: { (notification) in
            let uid = (notification.userInfo?["uid"] as! MIDIUniqueID?) ?? kMIDIInvalidUniqueID
            let endpoint=self.registered[uid]
            if endpoint != nil {
                let packets = notification.userInfo!["packets"] as! MIDIPacketList?
                if packets != nil { endpoint!.process(packets!) }
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(MIDIEndPointHandler.linkChanged(_:)), name: LinkManager.MIDILinkTableChanged, object: nil);
        
    }
    
    @objc private func linkChanged(_ n : NSNotification) {
        let info = n.userInfo
        if info==nil { return }
        let from=info!["from"] as! MIDIUniqueID? ?? kMIDIInvalidUniqueID
        let to=info!["to"] as! MIDIUniqueID? ?? kMIDIInvalidUniqueID
        let status=info!["linked"] as! Bool? ?? false
        cells[from]?.Linked = status ? to : kMIDIInvalidUniqueID
        cells[to]?.Linked = status ? from : kMIDIInvalidUniqueID
        table.reloadData()
    }
    
    
    public func register(endpoint : MIDIEndPoint) throws {
        let wrapper = try MIDIWrapEndPoint(endpoint: endpoint)
        if wrapper.isSource {
            let w = wrapper as! MIDISourceWrapper
            w.filtered=true
            w.setActivityAction({ (uid,active) in self.statusChange(uid,active) })
        }
        registered[endpoint.uid]=wrapper
        cells[endpoint.uid]=RowCellSet(endpoint: wrapper, handler: { (uid,status) in self.handleSwitches(uid,status) })
        //return wrapper
    }
    
    public func reset() {
        registered.removeAll()
    }
    
    public func load(endpoints: [MIDIEndPoint]) throws {
        try endpoints.forEach { (endpoint) in
            debugPrint("Creating session for \(endpoint) with name \(endpoint.Name)")
            try self.register(endpoint: endpoint)
        }
    }
    
    public func filtered(_ f: Bool) {
        registered.forEach { (arg) in
            let (_, wrapper) = arg
            if wrapper != nil && wrapper!.isSource {
                (wrapper! as! MIDISourceWrapper).filtered=f
            }
        }
    }
    
    // Callbacks
    
    public func preferencesChanged(_ preference: PreferencesReader) {
        enableActivityIndicators=preference.get(key: "enableActivity") ?? false
    }
    
    public func statusChange(_ uid: MIDIUniqueID, _ active: Bool) {
        if enableActivityIndicators { DispatchQueue.main.async { self.table.reloadData() } }
    }
    
    public func handleSwitches(_ uid: MIDIUniqueID,_ status : Bool) {
        debugPrint("Handling switch for \(uid) with status \(status)")
        let wrapper=registered[uid]
        if wrapper==nil { return }
        switch wrapper!.mode {
        case .Source:
            if status {
                let panel=DecoderPanel.launch(uid: uid)
                (wrapper! as! MIDISourceWrapper).startDecoding(interface: panel!)
            }
            else {
                let panel=DecoderPanel.close(uid: uid)
                panel?.unlink()
            }
            break
        case .Destination:
            break
        default:
            break
        }
        
            }
    
    // Table data source functions
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return registered.count
    }


    
    public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let wrapper=registered.at(index: row)
        if wrapper==nil { return nil }
        if tableColumn==nil { return nil }
        
        let column : String = tableColumn!.title
        let uid=wrapper!.uid
        let cellSet = cells[uid]
        if cellSet==nil { return nil }
        cellSet!.Active=wrapper!.isActive
        return cellSet![column]
    }
    
    // Table delegate methods
    
    public func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        if tableColumn.title=="Linked" {
            NotificationCenter.default.post(name: Controller.OpenLinkPanelRequest, object: nil)
        }
    }
    
    public func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return tableColumn?.title=="Linked"
    }
    
    public func tableView(_ tableView: NSTableView, shouldSelectRow: Int) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 21.0
    }
}

