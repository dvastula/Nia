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

extension CIImage {
  func getCGImage() -> CGImage? {
    let context = CIContext(options: nil)
    
    if let cgImage = context.createCGImage(self, from: self.extent) {
      return cgImage
    }
    
    return nil
  }
}

extension UIImage {
  
  /// Fix image orientaton to protrait up
  func fixedOrientation() -> UIImage? {
    guard imageOrientation != UIImage.Orientation.up else {
      // This is default orientation, don't need to do anything
      return self.copy() as? UIImage
    }
    
    guard let cgImage = self.cgImage else {
      // CGImage is not available
      return nil
    }
    
    guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
      return nil // Not able to create CGContext
    }
    
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    switch imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat.pi)
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat.pi / 2.0)
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: size.height)
      transform = transform.rotated(by: CGFloat.pi / -2.0)
    case .up, .upMirrored:
      break
    @unknown default:
      break
    }
    
    // Flip image one more time if needed to, this is to prevent flipped image
    switch imageOrientation {
    case .upMirrored, .downMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .leftMirrored, .rightMirrored:
      transform = transform.translatedBy(x: size.height, y: 0)
      transform = transform.scaledBy(x: -1, y: 1)
    case .up, .down, .left, .right:
      break
    @unknown default:
      break
    }
    
    ctx.concatenate(transform)
    
    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      break
    }
    
    guard let newCGImage = ctx.makeImage() else { return nil }
    return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
  }
}
