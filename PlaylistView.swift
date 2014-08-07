//
//  PlaylistView.swift
//  MusicToGo
//
//  Created by Andy Keller on 8/3/14.
//  Copyright (c) 2014 AppWelder. All rights reserved.
//

import Foundation

class PlaylistView {
    
    private var logText: String = ""
    private var progressMaxValue: Double = 1.0
    private var progressIndeterminate: Bool = true
    private var progressDoubleValue: Double = 0
    private var statusText: String = ""
    weak var app: AppDelegate?
    
    init(app: AppDelegate) {
        self.app = app
    }

    func busy() {
        progressMaxValue = 1
        progressIndeterminate = true
        progressDoubleValue = 0.5
        sync()
    }
    
    func setupProgress(max: Int) {
        progressDoubleValue = 0
        progressIndeterminate = false
        progressMaxValue = Double(max)
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
            logText += "\n\(err.description)\n\n"
        }
        sync()
    }
    
    // i originally thought we had to dispatch to the main queue to modify the UI, but that's not the case.
    func sync() {
        dispatch_sync(dispatch_get_main_queue()) {
            self.sync_()
        }
    }
    
    func sync_() {
        if let ui = app {
            if (logText != "") {
                ui.output.insertText(logText)
            }
            ui.progress.maxValue = progressMaxValue
            ui.progress.indeterminate = progressIndeterminate
            ui.progress.doubleValue = progressDoubleValue
            ui.status.stringValue = statusText
            logText = ""
        }
    }
}