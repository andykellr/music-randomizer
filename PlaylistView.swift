//
//  PlaylistView.swift
//  MusicToGo
//
//  Created by Andy Keller on 8/3/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class PlaylistView {
    
    weak var ui: AppDelegate!

    private var logText: String = ""
    private var progressMaxValue: Double = 1.0
    private var progressIndeterminate: Bool = true
    private var progressDoubleValue: Double = 0
    private var statusText: String = ""
    private var playlistSummary: String = ""
    private var destinationSummary: String = ""
    private var playlistInProgress: Bool = false
    private var destinationInProgress: Bool = false
    
    init(ui: AppDelegate) {
        self.ui = ui
    }

    func busy() {
        progressMaxValue = 1
        progressIndeterminate = true
        progressDoubleValue = 0.5
        sync()
    }
    
    func setPlaylistInProgress(playlistInProgress: Bool) {
        self.playlistInProgress = playlistInProgress
        sync()
    }
    
    func setDestinationInProgress(destinationInProgress: Bool) {
        self.destinationInProgress = destinationInProgress
        sync()
    }
    
    func setupProgress(max: Int) {
        progressDoubleValue = 0
        progressIndeterminate = false
        progressMaxValue = Double(max)
        sync()
    }
    
    func setPlaylistSummary(playlistSummary: String) {
        self.playlistSummary = playlistSummary
        sync()
    }
    
    func setDestinationSummary(destinationSummary: String) {
        self.destinationSummary = destinationSummary
        sync()
    }
    
    func setProgress(value: Int) {
        self.progressDoubleValue = Double(value)
        sync()
    }
    
    func setStatusText(statusText: String) {
        self.statusText = statusText
        sync()
    }
    
    func log(message: String) {
        logText += "\(message)\n"
        sync()
    }
    
    func logError(error: NSError?) {
        if let err = error {
            logText += "\n\(err.localizedDescription)\n\n"
        }
        sync()
    }
    
    // i originally thought we had to dispatch to the main queue to modify the UI, but that's not the case.
    func sync() {
        foreground {
            self.sync_()
        }
    }
    
    func sync_() {
        if (logText != "") {
            ui.output.insertText(logText)
        }
        ui.progress.maxValue = progressMaxValue
        ui.progress.indeterminate = progressIndeterminate
        ui.progress.doubleValue = progressDoubleValue
        ui.status.stringValue = statusText
        ui.playlistSummary.stringValue = playlistSummary
        ui.destinationSummary.stringValue = destinationSummary
        logText = ""
        
    }
}