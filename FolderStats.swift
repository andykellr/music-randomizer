//
//  FolderStats.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/8/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

//
// Assembles information about an output folder, using the Playlist to collect the files
//
class FolderStats {

    let path: String
    let playlist: Playlist
    weak var ui: PlaylistView!

    var free: Int = 0
    
    init(path: String, ui: PlaylistView) {
        self.path = path
        self.ui = ui
        self.playlist = Playlist(path: path)
        findFiles()
    }

    func refresh() {
        playlist.clear()
        findFiles()
    }
    
    func findFiles() {
        let fs = NSFileManager.defaultManager()
        var error: NSError?
        
        ui.setDestinationInProgress(true)
        
        // calculate free space
        let fsAttributes = fs.attributesOfFileSystemForPath(path, error: &error)!
        ui.logError(error)
        if let f: AnyObject = fsAttributes[NSFileSystemFreeSize] {
            free = f.integerValue
            ui.setDestinationSummary(summary)
        }
        
        // find files
        let enumerator = fs.enumeratorAtPath(path)
        while let file = enumerator.nextObject() as? String {
            
            // ignore . files like .Spotlight-V100
            if (file.hasPrefix(".")) {
                enumerator.skipDescendants()
                continue
            }
            
            // include the size
            let attrs = enumerator.fileAttributes!
            if let type = attrs[NSFileType] as? NSString {
                if type == NSFileTypeRegular {
                    if let size = attrs[NSFileSize]?.integerValue {
                        let entry = PlaylistEntry(path: path.stringByAppendingPathComponent(file), size: size)
                        playlist.append(entry)
                        ui.setDestinationSummary(summary)
                    }
                }
            }
        }
        
        ui.setDestinationInProgress(false)
    }
    
    var summary: String {
        get {
            let ret = "Path: \(path)\nFiles: \(playlist.count)\nUsed: \(formattedByteSize(playlist.size))"
            return free > 0 ? ret + "\nFree: \(formattedByteSize(free))" : ret
        }
    }
    
}