//
//  Preferences.swift
//  LazyNethack
//
//  Created by Philipp Tessenow on 2018-09-08.
//  Copyright © 2018 Tessi. All rights reserved.
//

import Foundation
import ScreenSaver

private var userDefaults: UserDefaults = {
    let ud =  ScreenSaverDefaults(forModuleWithName: "org.tessenow.LazyNethack") ?? UserDefaults()
    
    ud.register(defaults: [
        Preferences.Key.rowWidth.rawValue: Preferences.RowWidth.dynamic.rawValue,
        Preferences.Key.serverURL.rawValue: Preferences.RowWidth.dynamic.rawValue,
        Preferences.Key.font.rawValue: Preferences.RowWidth.dynamic.rawValue
        ])
    
    return ud
}()

struct Preferences {
    fileprivate enum Key: String {
        case rowWidth = "rowWidth-type"
        case font = "font-type"
        case serverURL = "serverURL-type"
    }
    
    enum RowWidth: Int {
        case dynamic
        case `static`
    }
    
    static var rowWidth: RowWidth {
        get {
            guard let width = RowWidth(rawValue: userDefaults.integer(forKey: Key.rowWidth.rawValue)) else { return .dynamic }
            return width
        }
        set {
            set(value: newValue.rawValue, key: .rowWidth)
        }
    }
  
    static var font: Font {
      get {
        guard let width = Font(rawValue: userDefaults.integer(forKey: Key.rowWidth.rawValue)) else { return .dynamic }
        return width
      }
      set {
        set(value: newValue.rawValue, key: .font)
      }
    }
  
  static var serverURL: ServerURL {
    get {
      guard let width = ServerURL(rawValue: userDefaults.integer(forKey: Key.rowWidth.rawValue)) else { return .dynamic }
      return width
    }
    set {
      set(value: newValue.rawValue, key: .serverURL)
    }
  }
    
    private static func set(value: Any, key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
        userDefaults.synchronize()
    }
}
