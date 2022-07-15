//
//  Exporter.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 07.07.2022.
//

import SwiftUI

enum ExportError: Error {
  case invalidFormat
}

class Exporter {
  
  @MainActor
  static func export(_ view: some View) -> URL {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let randomPrefix = UUID().uuidString.prefix(8)
    let fileURL = documentsURL.appendingPathComponent(randomPrefix + ".png")
        
    if let image = view.snapshot() {
      if let data = image.pngData() {
        try! data.write(to: fileURL)
      }
    }
    
    return fileURL
  }
}
