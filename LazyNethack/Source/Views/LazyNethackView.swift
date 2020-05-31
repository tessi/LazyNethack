//
//  LazyNethackView.swift
//  LazyNethack
//
//  Created by Philipp Tessenow on 2018-09-08.
//  Copyright © 2018-2020 Philipp Tessenow. All rights reserved.
//

import Foundation
import ScreenSaver
import WebKit

@objc(LazyNethackView)
class LazyNethackView: ScreenSaverView,
                       WKUIDelegate,
                       WKNavigationDelegate {
  
  var webView: WKWebView?
  var preferencesController: PreferencesWindowController?
  var startedFromTestApp = false
    
  // MARK: - Preferences
  override var hasConfigureSheet: Bool {
    return false
  }
  
  override var configureSheet: NSWindow? {
    if let controller = preferencesController {
      return controller.window
    }
  
    // let controller = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
    let controller = PreferencesWindowController(windowNibName: "PreferencesWindow")
  
    preferencesController = controller
    return controller.window
  }

  // entry point for when we are started within apples screensaver framework
  override init?(frame: NSRect, isPreview: Bool) {
    super.init(frame: frame, isPreview: isPreview)
    setup()
  }
  
  // entry point for when we are started within our own test-app
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    startedFromTestApp = true
    setup()
  }
  
  deinit {
   if let webView = webView {
      webView.uiDelegate = nil
      webView.navigationDelegate = nil
      webView.stopLoading();
    }
  }
    
  func setup() {
    autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
    autoresizesSubviews = true
    if startedFromTestApp { startAnimation() }
  }
  
  fileprivate func loadNethack() {
    let bundle = Bundle.init(for: type(of: self))
    let baseUrl = bundle.path(forResource: "index", ofType: "html")
    if let webView = webView, let baseUrl = baseUrl {
      let url = URL(fileURLWithPath: baseUrl, isDirectory: false)
      NSLog("nethack url: %@", url.absoluteString)
      webView.loadFileURL(url, allowingReadAccessTo: url)
    }
  }
  
  fileprivate func createWebView() {
    let webConfiguration = WKWebViewConfiguration()
    webConfiguration.applicationNameForUserAgent = "https://github.com/tessi/LazyNethack/issues"
    webView = WKWebView.init(frame: self.bounds, configuration: webConfiguration)
    if let webView = webView {
      webView.uiDelegate = self
      webView.navigationDelegate = self
      webView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
      webView.autoresizesSubviews = true
    }
  }
  
  override func startAnimation() {
    if !startedFromTestApp { super.startAnimation() }
  
    createWebView()
    if let webView = webView {
      addSubview(webView)
      
      let color = NSColor(calibratedWhite: 0.0, alpha: 1.0)
      if let layer = webView.layer {
        layer.backgroundColor = color.cgColor
      }
    }
    loadNethack()
  }
  
  override func stopAnimation() {
    super.stopAnimation()
    if let webView = webView {
      webView.removeFromSuperview()
      webView.stopLoading()
    }
    webView = nil
  }
  
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
