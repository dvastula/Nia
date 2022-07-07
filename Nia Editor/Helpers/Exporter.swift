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
    
    let renderer = ImageRenderer(content: view)
    renderer.scale = UIScreen.main.scale
    
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsURL.appendingPathComponent("exported.png")
        
    if let image = renderer.uiImage {
      if let data = image.pngData() {
        try? data.write(to: fileURL)
      }
    }
    
    return fileURL
  }
  
}
