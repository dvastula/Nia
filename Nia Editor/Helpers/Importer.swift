//
//  Importer.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 07.07.2022.
//

import SwiftUI
import PhotosUI

enum ImportError: Error {
  case invalidFormat
}

class Importer {
  
  static func `import`(_ photoItem: PhotosPickerItem) async throws -> Asset {
    
    if let data = try? await photoItem.loadTransferable(type: Data.self) {
      
      if let uiImage = UIImage(data: data) {
        print("Image or Animation imported")
        
        let newMedia = ImageAsset()
        newMedia.image = uiImage

        return newMedia
      }
    }

    throw ImportError.invalidFormat
  }
  
}
