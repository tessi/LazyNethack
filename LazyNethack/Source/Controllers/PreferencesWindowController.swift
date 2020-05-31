//
//  PreferencesWindowController.swift
//  LazyNethack
//
//  Created by Philipp Tessenow on 2018-09-08.
//  Copyright © 2018-2020 Philipp Tessenow. All rights reserved.
//

import Cocoa

@objc(PreferencesWindowController)
class PreferencesWindowController: NSWindowController {
    @IBOutlet weak var rowWidthSegment: NSSegmentedControl!
    
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
}
