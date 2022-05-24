//
//  StickerView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit

struct StickerView: View {
  @ObservedObject var mediaAsset: MediaAsset
  @State private var avPlayer: AVPlayer = AVPlayer()
  
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  @State private var scale: CGFloat = 1.0
  
  var body: some View {
    let rotationGesture = RotationGesture(minimumAngleDelta: .degrees(1))
      .onChanged { angle in
        mediaAsset.rotation = angle + rotation
      }
      .onEnded { angle in
        rotation = mediaAsset.rotation
      }
    
    let dragGesture = DragGesture()
      .onChanged { gesture in
        mediaAsset.offset = gesture.translation + offset
      }
      .onEnded { gesture in
        offset = mediaAsset.offset
      }
    
    let scaleGesture = MagnificationGesture()
      .onChanged { magnification in
        mediaAsset.scale = magnification * scale
      }
      .onEnded { angle in
        scale = mediaAsset.scale
      }
    
    let allGestures = dragGesture
      .simultaneously(with: rotationGesture)
      .simultaneously(with: scaleGesture)
    
    VStack {
      switch mediaAsset {
        case is ImageAsset:
          mediaAsset.image
            .resizable()
            .scaledToFit()
        case is VideoAsset:
//          if let url = (avPlayer.currentItem?.asset as? AVURLAsset)?.url {
//            VideoPlayer2(videoUrl: url)
//          }
//          
         VideoPlayer(player: avPlayer)
        default:
          Color.red
      }
    }
    .onAppear {
      if let videoAsset = mediaAsset as? VideoAsset {
        let item = AVPlayerItem(asset: videoAsset.avAsset)
        avPlayer = AVPlayer(playerItem: item)
        avPlayer.isMuted = true
        avPlayer.play()
      }
    }
    
    .frame(width: mediaAsset.frame.width,
           height: mediaAsset.frame.height,
           alignment: .topLeading)
    .scaleEffect(mediaAsset.scale)
    .rotationEffect(mediaAsset.rotation)
    .offset(mediaAsset.offset)
    .gesture(allGestures)
    .animation(.linear(duration: 0.1))
  }
}
