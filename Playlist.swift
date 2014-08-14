//
//  Playlist.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/8/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class PlaylistEntry {
    
    var path: String = ""
    var size: Int = 0
    var persistentId: String = ""

    init() {}
    init(path: String, size: Int) {
        self.path = path
        self.size = size
    }
    
    // ignore videos
    let ignoreExtensions = [
        "m4v": true,
        "mp4": true
    ]
    
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
    let path: String

    init(path: String) {
        self.path = path
        super.init()
    }
    
    override func append(value: AnyObject) {
        super.append(value)
        if let entry = value as? PlaylistEntry {
            size += entry.size
        }
    }
    
    override func clear() {
        super.clear()
        size = 0
    }
    
    var summary: String {
        return "Path: \(path)\nSongs: \(count)\nSize: \(formattedByteSize(size))"
    }
    
}
