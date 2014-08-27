//
//  FolderMenu.swift
//  Music Randomizer
//
//  Created by Andy Keller on 8/27/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Cocoa

//
// Delegate called when a new folder is selected using the folder menu
//
protocol FolderMenuDelegate: class {
    func folderMenu(menu: FolderMenu, didSelectFolder: FolderStats?)
}

class FolderMenu: NSObject, NSMenuDelegate {
    
    unowned let menuButton: NSPopUpButton
    unowned let ui: PlaylistView
    
    weak var delegate: FolderMenuDelegate?
    
    let chooseMusicItem = NSMenuItem(title: "Choose a music folder to randomize", action: "blankClick:", keyEquivalent: "")
    let chooseFolderItem = NSMenuItem(title: "Choose a folder...", action: "outputClick:", keyEquivalent: "")
    let chosenFolderItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    
    var menu: NSMenu {
        return menuButton.menu
    }

    var folderPath: String? {
        didSet {
            if let path = folderPath {
                if let url = NSURL.fileURLWithPath(path, isDirectory: true) {
                    let item = menuItemFromUrl(url)
                    
                    // keep the item the same but copy the details
                    chosenFolderItem.title = item.title
                    chosenFolderItem.image = item.image
                    chosenFolderItem.representedObject = item.representedObject
                }
                background {
                    self.folder = FolderStats(path: path, ui: self.ui)
                }
            }
            else {
                self.folder = nil
            }
            let item = getItemToSelect()
            item.hidden = false
            menuButton.selectItem(item)
        }
    }
    
    var folder: FolderStats? {
        didSet {
            if let d = delegate {
                d.folderMenu(self, didSelectFolder: folder)
            }
        }
    }
    
    init(menuButton: NSPopUpButton, ui: PlaylistView) {
        self.menuButton = menuButton
        self.ui = ui
        super.init()
        menuButton.menu.delegate = self
        chooseMusicItem.target = self
        chooseFolderItem.target = self
        chosenFolderItem.target = self
    }
    
    // MARK: - menu item actions
    
    func outputClick(sender: AnyObject) {
        let open = NSOpenPanel()
        open.canChooseDirectories = true
        open.canCreateDirectories = true
        open.canChooseFiles = false
        open.allowsMultipleSelection = false
        open.message = "Choose an output folder. Randomizer folders will be created in this folder."
        open.beginSheetModalForWindow(ui.ui.window, completionHandler: {
            if ($0 == NSOKButton) {
                self.folderPath = open.URL.path
            }
        })
    }
    func blankClick(sender: AnyObject) {
        self.folderPath = nil
    }
    func volumeClick(sender: AnyObject) {
        self.folderPath = menuButton.selectedItem.representedObject as? NSString
    }
    
    // MARK: - menu button delegate
    
    func clearStates() {
        for item in menu.itemArray as [NSMenuItem] {
            item.state = NSOffState
        }
    }
    
    func findMenuItem(path: String) -> NSMenuItem? {
        for item in menu.itemArray as [NSMenuItem] {
            if let menupath = item.representedObject as? String {
                if menupath == path && !item.hidden {
                    return item
                }
            }
        }
        return nil
    }
    
    func getItemToSelect() -> NSMenuItem {
        if let path = folderPath {
            if let item = findMenuItem(path) {
                return item
            }
            if (path == chosenFolderItem.representedObject as? NSString) {
                return chosenFolderItem
            }
        }
        return chooseMusicItem
    }
    
    func isChosenFolder() -> Bool {
        if let path = folderPath {
            return !isVolume()
        }
        return false
    }
    
    func selectFolderItem() {
        clearStates()
        
        if let path = folderPath {
            // we have a path, so select the item that matches
            if let item = findMenuItem(path) {
                item.state = NSOnState
            }
        }
        else {
            chooseMusicItem.state = NSOnState
        }
        
    }
    
    func isVolume() -> Bool {
        let volumes = ejectableVolumes
        for url in volumes {
            if let path = url.getResourceValue(NSURLPathKey) as? String {
                if path == folderPath {
                    return true
                }
            }
        }
        return false
    }
    
    //
    // Show the ejectable volumes in the menu
    //
    var ejectableVolumes: [NSURL] {
        get {
            let fs = NSFileManager.defaultManager()
            let urls = fs.mountedVolumeURLsIncludingResourceValuesForKeys([NSURLNameKey, NSURLPathKey, NSURLEffectiveIconKey, NSURLVolumeIsEjectableKey, NSURLVolumeIsInternalKey, NSURLVolumeIsLocalKey, NSURLVolumeIsRemovableKey], options: NSVolumeEnumerationOptions.SkipHiddenVolumes)
            return (urls as [NSURL]).filter({ (url) in
                return url.getResourceBool(NSURLVolumeIsEjectableKey, hasValue: true) &&
                //url.getResourceBool(NSURLVolumeIsInternalKey, hasValue: false) &&
                url.getResourceBool(NSURLVolumeIsLocalKey, hasValue: true) &&
                url.getResourceBool(NSURLVolumeIsRemovableKey, hasValue: true)
            })
        }
    }
    
    func menuNeedsUpdate(menu: NSMenu!) {
        // find the volumes and show them in the menu
        
        menu.autoenablesItems = false
        menu.removeAllItems()
        menu.addItem(chooseMusicItem)
        
        chosenFolderItem.hidden = !isChosenFolder()
        menu.addItem(chosenFolderItem)
        
        let volumes = ejectableVolumes
        if volumes.count > 0 {
            menu.addItem(NSMenuItem.separatorItem())
            
            let heading = NSMenuItem(title: "Ejectable volumes", action: nil, keyEquivalent: "")
            heading.enabled = false
            menu.addItem(heading)
        }
        
        for url: NSURL in volumes {
            let item = menuItemFromUrl(url)
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(chooseFolderItem)
        
        selectFolderItem()
    }
    
    func menuItemFromUrl(url: NSURL) -> NSMenuItem {
        let item = NSMenuItem()
        
        item.target = self
        item.action = "volumeClick:"
        if let title = url.getResourceValue(NSURLNameKey) as? NSString {
            item.title = title
        }
        if let image = url.getResourceValue(NSURLEffectiveIconKey) as? NSImage {
            image.size = NSSize(width: 16, height: 16)
            item.image = image
            item.indentationLevel = 1
        }
        // store the path
        let path = url.getResourceValue(NSURLPathKey) as String?
        item.representedObject = path
        
        return item
    }
    
}

