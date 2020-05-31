//
//  EventSinkView.swift
//  LazyNethack
//
//  Created by tessi on 01.06.20.
//  Copyright © 2020 Tessi. All rights reserved.
//

import Foundation
import AppKit

@objc(EventSinkView)
class EventSinkView : NSView {
  // MARK: - Focus Overrides
  // capture all the input events to prevent the webview from getting any keyboard focus.
  
  override func hitTest(_ point: NSPoint) -> NSView? {
    return self;
  }

  override func keyDown(with event: NSEvent) {
    return;
  }

  override func keyUp(with event: NSEvent) {
    return;
  }

  override var acceptsFirstResponder: Bool {
    return true;
  }

  override func resignFirstResponder() -> Bool {
    return false;
  }
}
