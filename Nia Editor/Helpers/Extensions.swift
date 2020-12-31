//
//  Extensions.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import CoreGraphics
import AVFoundation
import SwiftUI

func + (left: CGSize, right: CGSize) -> CGSize {
  return CGSize(width: left.width + right.width,
                height: left.height + right.height)
}

extension AVAsset {
  func preview() -> Image? {
    let imageGenerator = AVAssetImageGenerator(asset: self)
    imageGenerator.appliesPreferredTrackTransform = true
    
    var time = self.duration
    //If possible - take not the first frame (it could be completely black or white on camara's videos)
    time.value = min(time.value, 2)
    
    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      let uiImage = UIImage(cgImage: imageRef)
      
      return Image(uiImage: uiImage)
    } catch let error as NSError {
      print("Image generation failed with error \(error)")
      return nil
    }
  }
}
