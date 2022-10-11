//
//  MediaAsset.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 14.11.2020.
//

import SwiftUI
import AVKit

class Asset: Identifiable, ObservableObject, Equatable {
  static func == (lhs: Asset, rhs: Asset) -> Bool {
    lhs.image == rhs.image
  }
  
  @Published var duration: Double = 0
  @Published var frame: CGRect = .zero
  @Published var offset: CGSize = .zero
  @Published var rotation: Angle = .degrees(0)
  @Published var scale: CGFloat = 1
  @Published var image: UIImage = UIImage()
  @Published var originalImage: UIImage = UIImage()
  @Published var locked: Bool = false

  init(image: UIImage, frame: CGRect = .zero) {
    self.image = image
    self.originalImage = image
    self.frame = frame
  }

  var id = UUID()
}

class VideoAsset: Asset {
//  var avAsset: AVAsset
//
//  init(from avAsset: AVAsset) async {
//    self.avAsset = avAsset
//    super.init()
//
//    duration = try! await avAsset.load(.duration).seconds
//    frame = CGRect(x: 100, y: 100, width: 200, height: 200)
//
//    if let previewImage = await avAsset.preview() {
//      image = previewImage
//    }
//  }
}

class ImageAsset: Asset {
}
