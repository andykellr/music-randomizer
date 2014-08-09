//
//  FolderStats.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/8/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class FolderStats {

    var count: Int = 0
    var size: Int = 0
    var free: Int = 0
    
    init(path: String, ui: PlaylistView) {
        let fs = NSFileManager.defaultManager()
        var error: NSError?
        let enumerator = fs.enumeratorAtPath(path)
        while let f: AnyObject = enumerator.nextObject() {
            
            // ignore . files like .Spotlight-V100
            if (f.hasPrefix(".")) {
                enumerator.skipDescendants()
                continue
            }
            
            // include the size
            let attrs = enumerator.fileAttributes
            if let type = attrs[NSFileType] as? NSString {
                if type == NSFileTypeRegular {
                    if let filesize: AnyObject = attrs[NSFileSize] {
                        size += filesize.integerValue
                        count++
                        ui.setDestinationSummary(summary)
                    }
                }
            }
        }
        
        // calculate free space
        let fsAttributes = fs.attributesOfFileSystemForPath(path, error: &error)
        ui.logError(error)
        if let f: AnyObject = fsAttributes[NSFileSystemFreeSize] {
            free = f.integerValue
            ui.setDestinationSummary(summary)
        }
        
    }

    var summary: String {
        get {
            let ret = "Files: \(count)\nSize: \(formattedByteSize(size))"
            return free > 0 ? ret + ", Free: \(formattedByteSize(free))" : ret
        }
    }
    
}