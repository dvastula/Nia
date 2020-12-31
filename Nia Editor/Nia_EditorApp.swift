//
//  Nia_EditorApp.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 07.11.2020.
//

import SwiftUI

@main
struct Nia_EditorApp: App {
  var currentEditor: Editor = Editor()
  
  var body: some Scene {
    WindowGroup {
      PreviewScreen().environmentObject(currentEditor)
    }
  }
}
