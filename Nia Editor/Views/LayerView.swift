//
//  LayerView.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 16.07.2022.
//

import SwiftUI

struct LayerView: View {
  @ObservedObject var currentEditor: Editor
  @ObservedObject var layer: Layer
  
  var body: some View {
    ForEach(layer.assets) { asset in
      AssetView(mediaAsset: asset, locked: layer.locked)
    }
    .contextMenu {
      let _ = print("Context menu of:", layer)
      
      if layer.locked {
        Button {
          currentEditor.unlock(layer)
        } label: {
          Label("Unlock", systemImage: "lock.open.fill")
        }
      } else {
        Button {
          currentEditor.lock(layer)
        } label: {
          Label("Lock", systemImage: "lock.fill")
        }
      }
      
      Menu("Layout") {
        
        Button {
          withAnimation { () -> () in
            currentEditor.move(layer, .up)
          }
        } label: {
          Label("Layer up", systemImage: "arrow.up")
        }
        
        Button {
          withAnimation { () -> () in
            currentEditor.move(layer, .down)
          }
        } label: {
          Label("Layer down", systemImage: "arrow.down")
        }
        
        Button {
          withAnimation { () -> () in
            currentEditor.makeBackground(from: layer)
          }
        } label: {
          Label("Make it Background", systemImage: "square.3.layers.3d.bottom.filled")
        }
      }
      
      Menu("Magic") {
        
        Button {
          if let firstAsset = layer.assets.first,
             let assetCGImage = firstAsset.image.cgImage,
             let findedBody = BodySegmentation().process(image: assetCGImage) {
            
            withAnimation { () -> () in
              firstAsset.image = UIImage(cgImage: findedBody)
            }
          } else {
            print("ERROR while segmentation")
          }
        } label: {
          Label("Find a person", systemImage: "figure.wave")
        }
      }
      
      
      if let firstAsset = layer.assets.first,
         let imageView = Image(uiImage: firstAsset.image),
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
          currentEditor.remove(layer)
        }
      } label: {
        Label("Remove", systemImage: "trash.fill")
      }
    }

  }
  
}

