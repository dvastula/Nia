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

func < (left: CGSize, right: CGSize) -> Bool {
  return left.width < right.width && left.height < right.height
}

func > (left: CGSize, right: CGSize) -> Bool {
  return left.width > right.width && left.height > right.height
}

func / (left: CGSize, divider: Double) -> CGSize {
  return CGSize(width: left.width / divider,
                height: left.height / divider)
}

func * (left: CGSize, divider: Double) -> CGSize {
  return CGSize(width: left.width * divider,
                height: left.height * divider)
}


extension CGSize {
  
  func aspectFitRatio(inside size: CGSize) -> CGFloat {
    let widthRatio = size.width / self.width
    let heightRatio = size.height / self.height
    
    return min(widthRatio, heightRatio)
  }
  
  func aspectFit(into size: CGSize) -> CGSize {
    if self.width == 0.0 || self.height == 0.0 {
      return self
    }
    
    let aspectRatio = aspectFitRatio(inside: size)
    
    return CGSize(width: self.width * aspectRatio,
                  height: self.height * aspectRatio)
  }
  
  func aspectFill(into size: CGSize) -> CGSize {
    if self.width == 0.0 || self.height == 0.0 {
      return self
    }
    
    let widthRatio = size.width / self.width
    let heightRatio = size.height / self.height
    let aspectFillRatio = max(widthRatio, heightRatio)
    return CGSize(width: self.width * aspectFillRatio, height: self.height * aspectFillRatio)
  }
  
}

extension AVAsset {
  func preview() async -> Image? {
    let imageGenerator = AVAssetImageGenerator(asset: self)
    imageGenerator.appliesPreferredTrackTransform = true
    
    var time = try! await self.load(.duration)
    
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

extension View {
  @MainActor
  func snapshot() -> UIImage? {
    let renderer = ImageRenderer(content: self)
    renderer.scale = UIScreen.main.scale
    
    return renderer.uiImage
  }
}
