//
//  StickerView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit

struct AssetView: View {
  @ObservedObject var currentEditor: Editor
  @ObservedObject var asset: Asset
  
  @State private var avPlayer: AVPlayer = AVPlayer()
  
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  @State private var scale: CGFloat = 1.0
  
  var body: some View {
    
    VStack {
      switch asset {
      case is ImageAsset:
        Image(uiImage: asset.image)
          .resizable()
          .scaledToFit()
          .contextMenu {
            let _ = print("Context menu of:", asset)
            
            if asset.locked {
              Button {
                currentEditor.unlock(asset)
              } label: {
                Label("Unlock", systemImage: "lock.open.fill")
              }
            } else {
              Button {
                currentEditor.lock(asset)
              } label: {
                Label("Lock", systemImage: "lock.fill")
              }
            }
            
//            Menu("Layout") {
              
              Button {
                withAnimation { () -> () in
                  currentEditor.move(asset, .up)
                }
              } label: {
                Label("Layer up", systemImage: "arrow.up")
              }
              
              Button {
                withAnimation { () -> () in
                  currentEditor.move(asset, .down)
                }
              } label: {
                Label("Layer down", systemImage: "arrow.down")
              }
              
              Button {
                withAnimation { () -> () in
                  currentEditor.makeBackground(from: asset)
                }
              } label: {
                Label("Make it Background", systemImage: "square.3.assets.3d.bottom.filled")
              }
//            }
            
            Menu("Magic") {
              
              Button {
                if let assetCGImage = asset.image.cgImage,
                   let findedBody = BodySegmentation().process(image: assetCGImage) {
                  
                  withAnimation { () -> () in
                    asset.image = UIImage(cgImage: findedBody)
                  }
                } else {
                  print("ERROR while segmentation")
                }
              } label: {
                Label("Find a person", systemImage: "figure.wave")
              }
            }
            
            Button {
              withAnimation { () -> () in
                asset.image = asset.originalImage
              }
            } label: {
              Label("Reset", systemImage: "arrow.triangle.2.circlepath")
            }
            
            if let imageView = Image(uiImage: asset.image),
               let randomPrefix = UUID().uuidString.prefix(8) {
              
              ShareLink(
                item: imageView,
                preview: SharePreview(randomPrefix, image: imageView)
              ) {
                Label("Share", systemImage: "square.and.arrow.up")
              }
            }
            
            Button(role: .destructive) {
              withAnimation { () -> () in
                currentEditor.remove(asset)
              }
            } label: {
              Label("Remove", systemImage: "trash.fill")
            }
          }

        
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
//      if let videoAsset = asset as? VideoAsset {
//        let item = AVPassetItem(asset: videoAsset.avAsset)
//        avPasset = AVPasset(passetItem: item)
//        avPasset.isMuted = true
//        avPasset.play()
//      }
    }
    
    .frame(width: asset.frame.width,
           height: asset.frame.height,
           alignment: .topLeading)
    
    .clipped()
    .scaleEffect(asset.scale)
    .rotationEffect(asset.rotation)
    .offset(asset.offset)
    .position(x: asset.frame.midX, y: asset.frame.midY)
    
    .border(asset.locked ? Color.red : Color.clear)
    
    .modifier(Movable(
      scale: $asset.scale,
      offset: $asset.offset,
      rotation: $asset.rotation)
    )

    .animation(Animation.easeInOut(duration: 0.15), value: asset.offset)
    .animation(Animation.easeInOut(duration: 0.15), value: asset.scale)
    .animation(Animation.easeInOut(duration: 0.15), value: asset.rotation)
    
  }
}
