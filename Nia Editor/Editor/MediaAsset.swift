//
//  MediaAsset.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 14.11.2020.
//

import SwiftUI
import AVKit

class MediaAsset: Identifiable, ObservableObject {
  @Published var duration: Double = 0
  @Published var frame: CGRect!
  @Published var offset: CGSize = .zero
  @Published var rotation: Angle = .degrees(0)
  @Published var scale: CGFloat = 1

  var id = UUID()
  var image: Image = images.randomElement()!
  var color: Color = colors.randomElement()!
}

class VideoAsset: MediaAsset {
  var avAsset: AVAsset
  
  init(from avAsset: AVAsset) async {
    self.avAsset = avAsset
    super.init()

    self.duration = try! await avAsset.load(.duration).seconds
    self.frame = CGRect(x: 100, y: 100, width: 200, height: 200)
    
    if let previewImage = await avAsset.preview() {
      self.image = previewImage
    }
  }
}

class ImageAsset: MediaAsset {
}
