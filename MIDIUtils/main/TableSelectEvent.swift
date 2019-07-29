//
//  TableSelectEvent.swift
//  MIDIUtils
//
//  Created by Julian Porter on 27/07/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

import Foundation
import Cocoa
import CoreMIDI

public struct TableSelectEvent {
    public static let RowSelectedEvent = Notification.Name("_MIDIEndPointHandler.RowSelectedEvent")
    
    public let table : NSTableView
    public let uid : MIDIUniqueID
    
    public init(uid : MIDIUniqueID, table: NSTableView) {
        self.table=table
        self.uid=uid
    }
    public init?(notification: Notification) {
        if notification.name != TableSelectEvent.RowSelectedEvent { return nil }
        guard let t : NSTableView = notification.userInfo?["table"] as? NSTableView else { return nil }
        guard let u : MIDIUniqueID = notification.userInfo?["uid"] as? MIDIUniqueID else { return nil }
        self.table=t
        self.uid=u
    }
    
    public var notification : Notification {
        return Notification(name: TableSelectEvent.RowSelectedEvent, object: nil, userInfo: [
            "table" : self.table,
            "uid" : self.uid
        ])
    }
}
