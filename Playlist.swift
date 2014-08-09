//
//  Playlist.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/8/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class PlaylistEntry {
    
    // ignore videos
    let ignoreExtensions = [
        "m4v": true,
        "mp4": true
    ]
    
    var path: String = ""
    var size: Int = 0
    var persistentId: String = ""
    
    var valid: Bool {
        get {
            if path == "" {
                return false
            }
            if ignoreExtensions[path.pathExtension] != nil {
                return false
            }
            return true
        }
    }
}

class Playlist: SimpleList {

    var size: Int = 0
    
    override func append(value: AnyObject) {
        super.append(value)
        if let entry = value as? PlaylistEntry {
            size += entry.size
        }
    }
    
    var summary: String {
        return "Songs: \(count)\nSize: \(formattedByteSize(size))"
    }
    
}
