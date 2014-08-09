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
            case AfterKey
            case AfterValueStart
            case AfterValue
            case Other
        }
        
        // for feedback on the parsing process
        let ui: PlaylistView

        // state and key/value tracking
        var state: State = .Other
        var key: String = ""
        var value: String = ""
        
        // the current entry we're building
        var entry: PlaylistEntry = PlaylistEntry()
        
        // the list we're building
        var playlist: Playlist = Playlist()
        
        init(ui: PlaylistView) {
            self.ui = ui;
        }
        
        // the XML playlist format uses URLs and we need to remove the percent encoding
        func location(var loc: String) -> String {
            // we'll trim this from each file
            let fileprefix = "file://localhost"
            
            // strip the prefix if we have one
            if (loc.hasPrefix(fileprefix)) {
                loc = (loc as NSString).substringFromIndex(countElements(fileprefix))
            }
            
            return loc.stringByRemovingPercentEncoding
        }
        
        func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName : String!, attributes attributeDict: NSDictionary!) {
            
            switch (state) {
            case .AfterKey:
                switch (elementName!) {
                case "string", "integer", "date":
                    state = .AfterValueStart

                default:
                    break;
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
            
            if (state == .AfterValue) {
                
                switch (key) {
                case "Location":
                    entry.path = location(value)
                    
                case "Persistent ID":
                    entry.persistentId = value
                    
                case "Size":
                    if let size = value.toInt() {
                        entry.size = size
                    }
                    
                default:
                    break;
                }
                
                value = ""
                state = .Other
            }
            else if (elementName == "dict") {

                // end of a playlist entry, append
                if (entry.valid) {
                    
                    // include this entry
                    playlist.append(entry)
                    
                    // report our findings
                    ui.setPlaylistSummary(playlist.summary)
                }
                
                // reset
                entry = PlaylistEntry()
            }
        }
        
        func parser(parser: NSXMLParser!, foundCharacters string: String!) {
            
            switch (state) {
            case .AfterKeyStart, .AfterKey:
                key = string
                state = .AfterKey
                
            case .AfterValueStart, .AfterValue:
                value += string
                state = .AfterValue
                
            default:
                break;
            }
        }
        
        func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
            
        }
    }
    
    func parse(path: String, ui: PlaylistView) -> Playlist {
        
        var error: NSError?
        let data = NSData.dataWithContentsOfFile(path, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &error)
        if let err = error {
            ui.logError(error)
            return Playlist()
        }
        else {
            
            ui.setStatusText("Reading...")
            let parser = NSXMLParser(data: data)
            let delegate = Delegate(ui: ui)
            parser.delegate = delegate
            parser.parse()
            ui.setStatusText("Done")
            return delegate.playlist
        }
    }
    
}
