//
//  LinkTable.swift
//  MIDIUtils
//
//  Created by Julian Porter on 13/03/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import CoreMIDI



class MIDIIndicatorView : NSView {
    
    public var status : Bool=false {
        didSet {
            self.needsDisplay=true
        }
    }
    
    
    init(status s: Bool = false) {
        super.init(frame: NSZeroRect)
        initialise(status: status)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialise(status: false)
    }
    
    private func initialise(status s: Bool) {
        self.backgroundColor = .clear
        status=s
    }
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.clear.setFill()
        bounds.fill()
        
        if status {
            NSColor.green.setFill()
            let size=bounds.size
            let scale = Swift.max(1,Swift.min(size.width,size.height)-4)
            let offsetX = (size.width-scale)/2
            let offsetY = (size.height-scale)/2
            NSBezierPath(ovalIn: NSRect(x: offsetX, y: offsetY, width: scale, height: scale)).fill()
        }
    }
    
    
    
}



extension NSImageView {
    
    @discardableResult func setStatusImage(_ status : Bool = false) -> NSImageView {
        let name=(status) ? NSImage.statusAvailableName : NSImage.statusNoneName
        if let image=NSImage(named: name) {
            image.size = bounds.size
            self.image=image
        }
        return self
    }
}

class LinkageWindow : NSPanel, LaunchableItem, NSTableViewDelegate, NSTableViewDataSource {
    
    struct Tag : CustomStringConvertible, Hashable, Equatable   {
        public let from : Nameable
        public let to : Nameable
        
        public init(_ from: Nameable,_ to: Nameable) {
            self.from=from
            self.to=to
        }
        
        public var description: String { return "\(from.str):\(to.str)" }
        public func hash(into hasher: inout Hasher) { description.hash(into: &hasher) }
        public static func ==(_ l : Tag, _ r : Tag) -> Bool { return l.description == r.description }
        public static func !=(_ l : Tag, _ r : Tag) -> Bool { return l.description != r.description }
        
    }
    
    
    internal typealias ConnectionID = String
    static var nibname = NSNib.Name("LinkTable")
    static var lock = NSLock()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(LinkageWindow.updateTables(_:)), name: LinkManager.MIDILinkTableChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LinkageWindow.resizeColumns(_:)), name: NSWindow.didResizeNotification,object: nil)
        
    }
    @IBOutlet weak var table: NSTableView!
    
    private var links : ILinkTableSource!
    private var matrix : [Tag: NSView] = [:]
    private var rows : [MIDIUniqueID] = []
    private var columns : [MIDIUniqueID] = []

    
    
    @objc private func updateTables(_ n: NSNotification? = nil) {
        rows.forEach { (from) in
            columns.forEach { (to) in
                let tag=Tag(from,to)
                let field = (matrix[tag] as! MIDIIndicatorView?) ?? MIDIIndicatorView()
                if let status=links?[from,to] { field.status=status }
                matrix[tag]=field
            }
        }
        DispatchQueue.main.async {
            self.table.reloadData()
        }
    }
    
    private func columnNamed(name: String) -> NSTableColumn {
        let column=NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: name))
        column.title=name
        column.maxWidth=CGFloat.greatestFiniteMagnitude
        column.minWidth=0
        column.width=table.bounds.width/CGFloat(1+columns.count)
        column.headerCell.alignment = .center
        column.headerToolTip=links.tooltip(name)
        return column
    }
    
    private func makeCell(content: String = "",colour : NSColor = .black) -> VTextField {
        let field=VTextField(labelWithString: content)
        field.textColor=colour
        
        field.font=FontDescriptor.Small.font
        field.alignment = .center
        field.verticalAlignment = .middle
        return field
    }
    
    
    
    @objc private func resizeColumns(_ n: NSNotification) {
        if n.object is LinkageWindow?   {
            let width : CGFloat = table.bounds.width/CGFloat(1+columns.count)
            table.tableColumns.forEach { $0.width=width }
        }
        touch()
    }
    

    public func setDevices(_ manager: ILinkTableSource) {
        links=manager
        rows=links.fromLabels.map { $0 }
        columns=links.toLabels.map { $0 }
        updateTables()
        
        rows.forEach { (from) in
            columns.forEach { (to) in
                let tag=Tag(from,to)
                matrix[tag]=MIDIIndicatorView()
            }
            let cell=makeCell(content: from.hex,colour: .white)
            cell.toolTip=links.tooltip(from)
            matrix[Tag(from,"source")]=cell
        }
        debugPrint("\(matrix)")
        DispatchQueue.main.async {
            self.table.tableColumns.forEach { self.table.removeTableColumn($0) }
            self.table.addTableColumn(self.columnNamed(name: "source"))
            self.columns.forEach { self.table.addTableColumn(self.columnNamed(name: $0.hex )) }
        }
        
    }
    
    public func touch() {
        self.table.reloadData()
        self.viewsNeedDisplay=true
    }
    
 /*   func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        debugPrint("Object for row \(row) column \(tableColumn?.title)")
        if row < 0 || row >= rows.count { return nil }
        if tableColumn==nil { return nil }
        let source=rows[row]
        let tag=toTag(source,tableColumn!.title)
        return matrix[tag]
    }*/
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        debugPrint("View for row \(row) column \(String(describing: tableColumn?.title))")
        if row < 0 || row >= rows.count { return nil }
        if tableColumn==nil { return nil }
        let source=rows[row]
        let tag=Tag(source,tableColumn!.title)
        return matrix[tag]
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        debugPrint("Number of rows is \(rows.count)")
        return rows.count
    }
    
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 18
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldReorderColumn columnIndex: Int, toColumn newColumnIndex: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    
    @IBAction func didClick(_ tableView : NSTableView) {
        debugPrint("\(table.clickedColumn) - \(table.clickedRow)")
        if table.clickedColumn<1 || table.clickedColumn > columns.count { return }
        if table.clickedRow<0 || table.clickedRow >= rows.count { return }
        let source=links.fromLabels[table.clickedRow]
        let destination=links.toLabels[table.clickedColumn-1]
        let status=links[source,destination]
        
        do {
            if status { try links.unlink(from: source,to: destination) }
            else { try links.link(from: source,to: destination) }
        } catch LinkTableError.NoSuchEndpoint {
            debugPrint("One of the endpoints doesn't exist: \(source), \(destination)")
        } catch LinkTableError.LinkToItemAlreadyExists {
            debugPrint("The destination endpoint \(destination) is already linked")
        } catch LinkTableError.LinkFromItemAlreadyExists {
            debugPrint("The source endpoint \(source) is already linked")
        } catch LinkTableError.NoSuchLink {
            debugPrint("There is no link between \(source) and \(destination)")
        } catch {
            debugPrint("Catch-all: something unexpected happened")
        }
    }
    
    @IBAction func didDoubleClick(_ tableView : NSTableView) {
        
    }
    private static var the : LinkageWindow?
    
    

    

    public static func Create() -> LinkageWindow {
        if the == nil { the = instance() }
        return the!
    }
}


