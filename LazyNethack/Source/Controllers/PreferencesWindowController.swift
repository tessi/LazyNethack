//
//  PreferencesWindowController.swift
//  LazyNethack
//
//  Created by Philipp Tessenow on 2018-09-08.
//  Copyright © 2018 Tessi. All rights reserved.
//

import Cocoa

@objc(PreferencesWindowController)
class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var rowWidthSegment: NSSegmentedControl!
    @IBOutlet weak var fontSegment: NSSegmentedControl!
    @IBOutlet weak var serverURLSegment: NSSegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rowWidthSegment.selectedSegment = Preferences.rowWidth.rawValue
    }
    
    @IBAction func close(_ sender: Any) {
        guard let window = window else { return }
        NSApp.mainWindow?.endSheet(window)
    }
    
    @IBAction func rowWidthChanged(_ sender: Any) {
        if rowWidthSegment.selectedSegment == 0 {
            Preferences.rowWidth = .dynamic
        } else {
            Preferences.rowWidth = .`static`
        }
    }
  
  @IBAction func fontChanged(_ sender: Any) {
    if rowWidthSegment.selectedSegment == 0 {
      Preferences.font = .dynamic
    } else {
      Preferences.font = .`static`
    }
  }
  
  @IBAction func serverURLChanged(_ sender: Any) {
    if serverURLSegment.selectedSegment == 0 {
      Preferences.serverURL = .dynamic
    } else {
      Preferences.serverURL = .`static`
    }
  }
}
