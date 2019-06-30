//
//  highlighter.swift
//  MIDIUtils
//
//  Created by Julian Porter on 11/04/2019.
//  Copyright © 2019 JP Embedded Solutions. All rights reserved.
//

//
//  XMLHighlighter.swift
//  MIDIUtils
//
//  Created by Julian Porter on 14/07/2017.
//  Copyright © 2017 JP Embedded Solutions. All rights reserved.
//

import Cocoa
import MIDITools


extension NSMutableAttributedString {
    @discardableResult
    func app(string: String,attributes: [NSAttributedString.Key : Any]?) -> NSMutableAttributedString {
        self.append(NSMutableAttributedString(string: string, attributes: attributes))
        return self
    }
    
    @discardableResult
    func app(_ s: NSMutableAttributedString) -> NSMutableAttributedString {
        self.append(s)
        return self
    }
    
    func join(strings: [NSMutableAttributedString]) -> NSMutableAttributedString {
        if strings.count==0 { return NSMutableAttributedString() }
        if strings.count==1 { return strings.first! }
        let out = NSMutableAttributedString()
        
        Array(strings.prefix(strings.count-1)).forEach {
            out.app($0).append(self)
        }
        return out.app(strings.last!)
    }
}

public class Highlighter : NSObject, XMLParserDelegate, PreferenceListener {
    
    
    
    private struct AttributeSet {
        public let rawValue : [NSAttributedString.Key : Any]
        
        public init(font: Font?=nil,colour: Colour?=nil) {
            var rv : [NSAttributedString.Key : Any] = [:]
            if font != nil { rv[.font] = font!.font }
            if colour != nil { rv[.foregroundColor] = colour!.colour }
            rawValue=rv
        }
        
        public init(_ preferences: PreferencesReader,colour: String) {
            let font : Font? = preferences.get(key: "printFont")
            let colour : Colour? = preferences.get(key: "xmlTextColour")
            self.init(font: font, colour: colour)
        }
    }
    private enum Kind {
        case text
        case attributeText
        case element
        case attribute
        case header
    }
    
    private var attributes : [Kind: AttributeSet]
    
    private var font : Font!
    private var separator : NSMutableAttributedString!
    private var paragraphIndent : UInt
    
    
    private var document: Data!
    private var out : NSMutableAttributedString
    private var error : Error! = nil
    private var last : Kind?
    private var lb : String
    private var decoder : MIDIDecoderBase!
    private var view : NSTextView!
    
    
    
    public init(view v: NSTextView!) {
        view=v
        out=NSMutableAttributedString()
        attributes=[:]
        paragraphIndent=0
        last=nil
        lb=""
        super.init()
        preferencesChanged(PreferencesReader())
    }
    
    func Touch() {
        DispatchQueue.main.async {
            try? self.parse()
        }
    }
    
    func link(decoder d:MIDIDecoderBase) {
        decoder=d
        decoder.action = { self.Touch() }
        
        let converter=BaseMIDISerialiser<XMLSerialisationElement>(messages: decoder?.content ?? [])
        document=converter.data
    }
    
    
    
    public func preferencesChanged(_ p: PreferencesReader) {
        attributes[.text]=AttributeSet(p, colour: "xmlTextColour")
        attributes[.attributeText]=AttributeSet(p, colour: "xmlAttributeColour")
        attributes[.element]=AttributeSet(p, colour: "xmlElementColour")
        attributes[.attribute]=AttributeSet(p, colour: "xmlAttributeColour")
        attributes[.header]=AttributeSet(p, colour: "xmlHeaderColour")
        separator=NSMutableAttributedString(string: " ",attributes: self[.text])
        lb = (p.get(key:"prettyPrint") ?? false) ? "\n" : ""
        Touch()
    }
    
    private subscript(_ kind : Kind) -> [NSAttributedString.Key : Any]? {
        return attributes[kind]?.rawValue
    }
    
    public func parse() throws {
        last=nil
        let parser=XMLParser.init(data: document)
        parser.delegate=self
        out=NSMutableAttributedString()
        if !parser.parse() { throw error }
        self.view.textStorage?.setAttributedString(out)
    }
    
    private func str(_ s: String,_ kind: Kind) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: s,attributes: self[kind])
    }
    
    // delegate methods
    
    public func parserDidStartDocument(_ parser: XMLParser) {
        out=NSMutableAttributedString()
        
    }
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        out.fixAttributes(in: NSMakeRange(0, out.length))
    }
    
    private var prefix : String {
        return String.init(repeating: " ", count: 2*Int(paragraphIndent))
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        
        let attributes : NSMutableAttributedString = separator.join(strings:
            attributeDict.map { (kv) in
                let s : NSMutableAttributedString = str("\(kv.key)=\"",.attribute)
                    .app(string:"\(kv.value)",attributes:self[.attributeText])
                    .app(string:"\"\(lb)",attributes:self[.attribute])
                return s
        })
        out.app(string:"\(prefix)<\(elementName)",attributes:self[.element]).app(attributes).app(string:">\(lb)",attributes:self[.element])
        last = .element
        paragraphIndent+=1
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        paragraphIndent-=1
        let str=(last == .text) ? lb : ""
        out.app(string:"\(str)\(prefix)</\(elementName)>\(lb)",attributes:self[.element])
        last = .element
        
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        out.app(string:"\(prefix)\(string)",attributes:self[.text])
        last = .text
    }
    
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        error=parseError
        parser.abortParsing()
    }
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        error=validationError
        parser.abortParsing()
    }
    
    
    
    
    
}

