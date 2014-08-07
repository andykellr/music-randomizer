//
//  PlaylistParser.swift
//  MusicToGo
//
//  Created by Andy Keller on 8/1/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

//
// Parses an XML playlist produced from iTunes using right click > Export... 
// and selecting XML as the playlist format.
//
class PlaylistParser {

    class Delegate: NSObject, NSXMLParserDelegate {
        enum State {
            case AfterKeyStart
            case AfterLocationKey
            case AfterLocationStringStart
            case AfterLocationString
            case Other
        }
        
        let ui: PlaylistView
        var state: State = .Other
        var current: String = ""
        var items: SimpleList = SimpleList()
        var fileprefix = "file://localhost"
        
        init(ui: PlaylistView) {
            self.ui = ui;
        }
        
        func parser(parser: NSXMLParser!,didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
            
            switch (state) {
            case .AfterLocationKey:
                if (elementName == "string") {
                    state = .AfterLocationStringStart
                }
                
            default:
                if (elementName == "key") {
                    state = .AfterKeyStart
                }
                else {
                    state = .Other
                }
                break;
            }
        }
        
        func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!) {
            
            if (state == .AfterLocationString) {

                // strip the prefix if we have one
                if (current.hasPrefix(fileprefix)) {
                    current = (current as NSString).substringFromIndex(countElements(fileprefix))
                }

                items.append(current)
                ui.setStatusText("Found \(items.count) files")
                
                current = ""
                state = .Other
            }
        }
        
        func parser(parser: NSXMLParser!, foundCharacters string: String!) {
            
            switch (state) {
            case .AfterKeyStart:
                if (string == "Location") {
                    state = .AfterLocationKey
                }
                
            case .AfterLocationStringStart, .AfterLocationString:
                
                // the XML playlist format uses URLs and we need to remove the percent encoding
                current += string.stringByRemovingPercentEncoding
                state = .AfterLocationString
                
            default:
                break;
            }
        }
        
        func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
            
        }
    }
    
    func parse(path: String, ui: PlaylistView) -> SimpleList {
        
        var error: NSError?
        let data = NSData.dataWithContentsOfFile(path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        if let err = error {
            ui.logError(error)
            return SimpleList()
        }
        else {
            let parser = NSXMLParser(data: data)
            let delegate = Delegate(ui: ui)
            parser.delegate = delegate
            parser.parse()
            return delegate.items
        }
    }
    
}
