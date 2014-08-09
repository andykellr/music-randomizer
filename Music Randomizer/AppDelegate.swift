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
    @IBOutlet weak var playlistSummary: NSTextField!
    @IBOutlet weak var destinationSummary: NSTextField!

    @IBOutlet weak var playlistProgress: NSProgressIndicator!
    @IBOutlet weak var destinationProgress: NSProgressIndicator!
    
    @IBAction func playlistClick(sender: AnyObject) {
        let open = NSOpenPanel()
        open.canChooseDirectories = false
        open.canCreateDirectories = false
        open.canChooseFiles = true
        open.allowsMultipleSelection = false
        open.allowedFileTypes = [ "xml" ]
        open.message = "Choose the XML playlist that you exported from iTunes"
        open.beginSheetModalForWindow(window, completionHandler: {
            if ($0 == NSOKButton) {
                let path = open.URL.path
                self.playlist.stringValue = path
                background {
                    self.list = PlaylistParser().parse(path, ui: self.ui)
                }
            }
        })
    }
    @IBAction func outputClick(sender: AnyObject) {
        let open = NSOpenPanel()
        open.canChooseDirectories = true
        open.canCreateDirectories = true
        open.canChooseFiles = false
        open.allowsMultipleSelection = false
        open.message = "Choose an output folder. Randomizer folders will be created in this folder."
        open.beginSheetModalForWindow(window, completionHandler: {
            if ($0 == NSOKButton) {
                let path = open.URL.path
                self.destination.stringValue = path
                background {
                    self.ui.log(path)
                    var stats = FolderStats(path: path, ui: self.ui)
                }
            }
        })
    }
    
    @IBAction func copyFilesClick(sender: AnyObject) {
        // do the copy in the background because on USB 2.0 this can take hours
        background {
            self.copyFiles()
        }
    }
    
    var ui: PlaylistView!
    var output: NSTextView {
        return scrollView.contentView.documentView as NSTextView
    }
    
    // a parsed playlist that will be initialized when a file is opened
    var list: SimpleList?
    
    let fs = NSFileManager.defaultManager()
    
    var subfoldersValue: Int {
        return subfolders.selectedItem.title.toInt()!
    }

    func setDefaults() {
        playlist.stringValue = "~/Desktop/Tesla.xml".stringByExpandingTildeInPath
        destination.stringValue = "~/Desktop/test".stringByExpandingTildeInPath
        status.stringValue = ""
        playlistSummary.stringValue = ""
        destinationSummary.stringValue = ""
        
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
    
    func parsePlaylist(path: String) {
        list = PlaylistParser().parse(path, ui: ui)
    }
    
    func copyFiles() {
        progress.doubleValue = 0
        
        let path = playlist.stringValue
        
        ui.busy()
        
        if list == nil {
            list = PlaylistParser().parse(path, ui: ui)
        }
        let files = PlaylistFiles(files: list!, destinationPath: destination.stringValue, subfolderCount: subfoldersValue)
        
        ui.log("Found \(files.count) files in playlist.")
        
        ui.setupProgress(files.count)
        
        let iterator = files.files.iterator()
        while let (obj: AnyObject, i: Int) = iterator.next() {
            let file = obj as PlaylistEntry
            
            ui.setStatusText("\(i+1) of \(files.count)")
            
            var (src, dest, name) = files.getPaths(i, file: file.path)
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
        ui = PlaylistView(ui: self)
        
        // Insert code here to initialize your application
        setDefaults()
        
        // for now, pretend that we clicked the Copy Files button
        //copyFiles()
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        // Insert code here to tear down your application
    }
    
}


