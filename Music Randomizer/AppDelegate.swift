//
//  AppDelegate.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/7/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var playlist: NSTextField!
    @IBOutlet weak var destination: NSTextField!
    @IBOutlet weak var subfolders: NSPopUpButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var status: NSTextField!

    
    var ui: PlaylistView!
    var output: NSTextView {
        return scrollView.contentView.documentView as NSTextView
    }
    
    let fs = NSFileManager.defaultManager()
    
    var subfoldersValue: Int {
        return subfolders.selectedItem.title.toInt()!
    }
    
    @IBAction func copyFilesClick(sender: AnyObject) {
        // do the copy in the background because on USB 2.0 this can take hours
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.copyFiles()
        })
    }
    
    func setDefaults() {
        playlist.stringValue = "~/Desktop/Tesla.xml".stringByExpandingTildeInPath
        destination.stringValue = "~/Desktop/test".stringByExpandingTildeInPath
        status.stringValue = ""
        
        // 5-50, by 5s
        let options = [Int](1...10).map { String($0 * 5) }
        subfolders.addItemsWithTitles(options)
        subfolders.selectItemWithTitle("10")
    }
    
    func removeAnyExistingFile(path: String) -> Bool {
        var error: NSError?
        if fs.fileExistsAtPath(path) {
            fs.removeItemAtPath(path, error: &error)
            if let err = error {
                ui.logError(err)
                return false
            }
        }
        return true
    }
    
    func mkdirs(path: String, inout error: NSError?) {
        if (!fs.fileExistsAtPath(path)) {
            fs.createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
    }
    
    func mkdirs(path: String) {
        let folder = path.stringByDeletingLastPathComponent
        var error: NSError?
        mkdirs(folder, error: &error)
        if let err = error {
            ui.logError(err)
        }
    }
    
    func copyFiles() {
        progress.doubleValue = 0
        
        let path = playlist.stringValue
        
        ui.busy()
        
        let list = PlaylistParser().parse(path, ui: ui)
        let files = PlaylistFiles(files: list, destinationPath: destination.stringValue, subfolderCount: subfoldersValue)
        
        ui.log("Found \(files.count) files in playlist:")
        
        ui.setupProgress(files.count)
        
        let iterator = files.files.iterator()
        while let (file: AnyObject, i: Int) = iterator.next() {
            ui.setStatusText("\(i+1) of \(files.count)")
            
            var (src, dest, name) = files.getPaths(i, file: file as String)
            var error: NSError?
            
            ui.log("\(src) => \(dest)")
            
            // we can't overwrite using copyItemAtPath, so we delete first
            if removeAnyExistingFile(dest) {
                mkdirs(dest)
                fs.copyItemAtPath(src, toPath: dest, error: &error)
                ui.logError(error)
            }
            
            ui.setProgress(i+1)
        }
        
        ui.setStatusText("Finished")
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        ui = PlaylistView(app: self)
        
        // Insert code here to initialize your application
        setDefaults()
        
        // for now, pretend that we clicked the Copy Files button
        //copyFiles()
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
}


