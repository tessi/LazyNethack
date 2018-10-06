//
//  LazyNethackView.swift
//  LazyNethack
//
//  Created by Philipp Tessenow on 2018-09-08.
//  Copyright © 2018 Tessi. All rights reserved.
//

import Foundation
import ScreenSaver
import WebKit

@objc(LazyNethackView)
class LazyNethackView: ScreenSaverView,
                       WebEditingDelegate,
                       WebFrameLoadDelegate,
                       WebPolicyDelegate,
                       WebUIDelegate {
  
  var webView: WebView?
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
  
//    let controller = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
    let controller = PreferencesWindowController(windowNibName: NSNib.Name("PreferencesWindow"))
  
    preferencesController = controller
    return controller.window
  }

  // entry point for when we are started within apples screensaber framework
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
      webView.frameLoadDelegate = nil
      webView.policyDelegate = nil
      webView.uiDelegate = nil
      webView.editingDelegate = nil
      webView.close()
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
      var url = "file://" + baseUrl
      if isPreview { url = url + "?preview=true" }
      NSLog("nethack url: %@", url)
      webView.mainFrameURL = url
    }
  }
  
  fileprivate func createWebView() {
    webView = WebView(frame: self.bounds)
    if let webView = webView {
      webView.frameLoadDelegate = self
      webView.shouldUpdateWhileOffscreen = true
      webView.policyDelegate = self
      webView.uiDelegate = self
      webView.editingDelegate = self
      webView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
      webView.autoresizesSubviews = true
      webView.drawsBackground = false
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
      webView.close()
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
  
  // MARK: - WebPolicyDelegate

  func webView(_ webView: WebView!, decidePolicyForNewWindowAction actionInformation: [AnyHashable : Any]!, request: URLRequest!, newFrameName frameName: String!, decisionListener listener: WebPolicyDecisionListener!) {
    // Don't open new windows.
    listener.ignore()
  }

  func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
    if let webView = webView {
      webView.resignFirstResponder()
      webView.mainFrame.frameView.allowsScrolling = false
      //  webView.drawsBackground = true
    }
  }

  func webView(_ webView: WebView!, unableToImplementPolicyWithError error: Error!, frame: WebFrame!) {
    NSLog("unableToImplement: %@", error.localizedDescription)
  }
  
  // MARK: - WebUIDelegate
  func webViewFirstResponder(_ sender: WebView!) -> NSResponder! {
    return self;
  }

  func webViewClose(_ sender: WebView!) {
    return;
  }

  func webViewIsResizable(_ sender: WebView!) -> Bool {
    return false;
  }
  
  func webViewIsStatusBarVisible(_ sender: WebView!) -> Bool {
    return false;
  }
  
  func webViewRunModal(_ sender: WebView!) {
    return;
  }

  func webViewShow(_ sender: WebView!) {
    return;
  }

  func webViewUnfocus(_ sender: WebView!) {
    return;
  }
}
