//
//  AppDelegate.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/7/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Cocoa


extension NSURL {
    //
    // Simpler version of getResourceValue
    //
    func getResourceValue(forKey: String) -> AnyObject? {
        var value: AnyObject?
        var error: NSError?
        self.getResourceValue(&value, forKey: forKey, error: &error)
        if error == nil {
            return value
        }
        return nil
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
                            
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var copyButton: NSButton!
    @IBOutlet weak var reshuffleButton: NSButton!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var subfolders: NSPopUpButton!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var playlistSummary: NSTextField!
    @IBOutlet weak var destinationSummary: NSTextField!
    @IBOutlet weak var outputMenu: NSPopUpButton!

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
                if let path = open.URL.path {
                    background {
                        self.playlist = PlaylistParser().parse(path, ui: self.ui)
                    }
                }
            }
        })
    }
    func outputClick(sender: AnyObject) {
        let open = NSOpenPanel()
        open.canChooseDirectories = true
        open.canCreateDirectories = true
        open.canChooseFiles = false
        open.allowsMultipleSelection = false
        open.message = "Choose an output folder. Randomizer folders will be created in this folder."
        open.beginSheetModalForWindow(window, completionHandler: {
            if ($0 == NSOKButton) {
                if let path = open.URL.path {
                    background {
                        self.folder = FolderStats(path: path, ui: self.ui)
                    }
                }
            }
        })
    }
    func blankClick(sender: AnyObject) {
        self.folder = nil
    }
    func volumeClick(sender: AnyObject) {
        if let path = outputMenu.selectedItem.representedObject as? NSString {
            background {
                self.folder = FolderStats(path: path, ui: self.ui)
            }
        }
    }
    
    @IBAction func copyFilesClick(sender: AnyObject) {
        // do the copy in the background because on USB 2.0 this can take hours
        background {
            self.copyFiles()
        }
    }
    @IBAction func reshuffleClick(sender: AnyObject) {
        background {
            self.reshuffle()
        }
    }
    
    var ui: PlaylistView!
    var output: NSTextView {
        return scrollView.contentView.documentView as NSTextView
    }
    
    // a parsed playlist that will be initialized when a file is opened
    var playlist: Playlist? {
        didSet {
            updateButtonStates(busy: false)
        }
    }
    var folder: FolderStats? {
        didSet {
            updateButtonStates(busy: false)
            if folder == nil {
                destinationSummary.stringValue = ""
            }
        }
    }
    func updateButtonStates(#busy: Bool) {
        copyButton.enabled = !busy && folder != nil && playlist != nil
        reshuffleButton.enabled = !busy && folder != nil
    }
    
    let fs = NSFileManager.defaultManager()
    
    var subfoldersValue: Int {
        return subfolders.selectedItem.title.toInt()!
    }

    func setDefaults() {
        status.stringValue = ""
        playlistSummary.stringValue = ""
        destinationSummary.stringValue = ""
        
        // 5-50, by 5s
        let options = [Int](1...10).map { String($0 * 5) }
        subfolders.addItemsWithTitles(options)
        subfolders.selectItemWithTitle("10")
        
        updateButtonStates(busy: false)
        
        setupOutputMenu()
    }

    func setupOutputMenu() {
        // find the volumes and show them in the menu
        
        outputMenu.menu.autoenablesItems = false
        outputMenu.menu.removeAllItems()
        
        let fs = NSFileManager.defaultManager()
        let urls = fs.mountedVolumeURLsIncludingResourceValuesForKeys([NSURLNameKey, NSURLPathKey, NSURLEffectiveIconKey, NSURLVolumeIsEjectableKey], options: NSVolumeEnumerationOptions.SkipHiddenVolumes)
        
        let choose = NSMenuItem(title: "Choose an output folder", action: "blankClick:", keyEquivalent: "")
        outputMenu.menu.addItem(choose)
        outputMenu.menu.addItem(NSMenuItem.separatorItem())

        let heading = NSMenuItem(title: "Ejectable volumes", action: nil, keyEquivalent: "")
        heading.enabled = false
        outputMenu.menu.addItem(heading)
        
        for url: NSURL in urls as [NSURL] {
            if let ejectable = url.getResourceValue(NSURLVolumeIsEjectableKey) as? Bool {
                if ejectable {
                    let item = NSMenuItem()

                    item.action = "volumeClick:"
                    if let title = url.getResourceValue(NSURLNameKey) as? NSString {
                        item.title = title
                    }
                    if let image = url.getResourceValue(NSURLEffectiveIconKey) as? NSImage {
                        image.size = NSSize(width: 18, height: 18)
                        item.image = image
                        item.indentationLevel = 1
                    }
                    // store the path
                    item.representedObject = url.getResourceValue(NSURLPathKey)
                    
                    outputMenu.menu.addItem(item)
                }
            }
        }

        outputMenu.menu.addItem(NSMenuItem.separatorItem())

        outputMenu.menu.addItem(NSMenuItem(title: "Other folder...", action: "outputClick:", keyEquivalent: ""))
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
        
        if let p = playlist {
            if let f = folder {
                updateButtonStates(busy: true)
                ui.busy()
                
                let files = PlaylistFiles(files: p, destinationPath: f.path, subfolderCount: subfoldersValue)
                
                ui.setupProgress(files.count)
                
                let iterator = files.files.iterator()
                while let (obj: AnyObject, i: Int) = iterator.next() {
                    let file = obj as PlaylistEntry
                    
                    ui.setStatusText("\(i+1) of \(files.count)")
                    
                    let src = file.path
                    var (dest, name) = files.getPaths(i, file: src)
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
                updateButtonStates(busy: false)
                
                f.refresh()
            }
        }
    }
    
    func reshuffle() {
        progress.doubleValue = 0
        
        if let f = folder {
            updateButtonStates(busy: true)
            
            let files = PlaylistFiles(files: f.playlist, destinationPath: f.path, subfolderCount: subfoldersValue)
            
            ui.setupProgress(files.count)
            
            let iterator = files.files.iterator()
            while let cur = iterator.next() {
                let file = cur.value as PlaylistEntry
                let i = cur.index

                ui.setStatusText("\(i+1) of \(files.count)")
                
                let src = file.path
                var (dest, name) = files.getPaths(i, file: src)
                var error: NSError?
                
                ui.log("\(src) => \(dest)")
                
                // make sure nothing is already there. in the unlikely case that something is there, just do nothing.
                if !fs.fileExistsAtPath(dest) {
                    mkdirs(dest)
                    fs.moveItemAtPath(src, toPath: dest, error: &error)
                    ui.logError(error)
                }
                else {
                    ui.log("- Skipping because file already exists at \(dest)")
                }
                
                ui.setProgress(i+1)
            }
            
            ui.setStatusText("Finished")
            updateButtonStates(busy: false)
            
            f.refresh()
        }
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


