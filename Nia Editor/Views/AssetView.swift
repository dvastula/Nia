//
//  StickerView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit

struct AssetView: View {
  @ObservedObject var mediaAsset: Asset
  @State private var avPlayer: AVPlayer = AVPlayer()
  
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  @State private var scale: CGFloat = 1.0
  
  var body: some View {
    
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
    
    //    ShareLink(
    //      item: mediaAsset.image,
    //      subject: Text("Cool Photo"),
    //      message: Text("Check it out!"),
    //      preview: SharePreview(
    //        "sup",
    //        image: mediaAsset.image))
    
    //    .contentShape(Rectangle())
    //    .contextMenu {
    //      Button {
    //        print("Change country setting")
    //      } label: {
    //        Label("Choose Country", systemImage: "globe")
    //      }
    //
    //      Button {
    //        print("Enable geolocation")
    //      } label: {
    //        Label("Detect Location", systemImage: "location.circle")
    //      }
    //    }
    
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
    .position(x: mediaAsset.frame.midX, y: mediaAsset.frame.midY)
    
    .modifier(Movable(
      scale: $mediaAsset.scale,
      offset: $mediaAsset.offset,
      rotation: $mediaAsset.rotation)
    )

    .animation(Animation.easeInOut(duration: 0.15), value: mediaAsset.offset)
    .animation(Animation.easeInOut(duration: 0.15), value: mediaAsset.scale)
    .animation(Animation.easeInOut(duration: 0.15), value: mediaAsset.rotation)
  }
}
