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
  
  var webView: WebView!
  var preferencesController: PreferencesWindowController?
    
  // MARK: - Preferences
  override var hasConfigureSheet: Bool {
    return false
  }
  
  override var configureSheet: NSWindow? {
    if let controller = preferencesController {
      return controller.window
    }
  
    let controller = PreferencesWindowController(windowNibName: NSNib.Name(rawValue: "PreferencesWindow"))
  
    preferencesController = controller
    return controller.window
  }

  override init?(frame: NSRect, isPreview: Bool) {
    super.init(frame: frame, isPreview: isPreview)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  deinit {
    if isPreview { return }
    webView.frameLoadDelegate = nil
    webView.policyDelegate = nil
    webView.uiDelegate = nil
    webView.editingDelegate = nil
    webView.close()
  }
    
  func setup() {
    autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
    autoresizesSubviews = true
    // startAnimation()
  }
  
  fileprivate func loadNethack() {
    let bundle = Bundle.init(for: type(of: self))
    let url = bundle.path(forResource: "index", ofType: "html")
    NSLog("url: %@", url ?? "<nil>")
    webView.mainFrameURL = url
  }
  
  override func startAnimation() {
    super.startAnimation()
    if isPreview { return }
  
    webView = WebView(frame: self.bounds)
    webView.frameLoadDelegate = self
    webView.shouldUpdateWhileOffscreen = true
    webView.policyDelegate = self
    webView.uiDelegate = self
    webView.editingDelegate = self
    webView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
    webView.autoresizesSubviews = true
    webView.drawsBackground = false
    addSubview(self.webView)
    
    let color = NSColor(calibratedWhite: 0.0, alpha: 1.0)
    webView.layer?.backgroundColor = color.cgColor
    
    loadNethack()
  }
  
  override func stopAnimation() {
    super.stopAnimation()
    if isPreview { return }
    webView.removeFromSuperview()
    webView.close()
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
    webView.resignFirstResponder()
    webView.mainFrame.frameView.allowsScrolling = false
    //  webView.drawsBackground = true
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
