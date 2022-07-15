//
//  PreviewView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI

struct PreviewView: View {
  @EnvironmentObject var currentEditor: Editor
  
  var body: some View {
    ZStack {
      ForEach(currentEditor.layers) { layer in
        ForEach(layer.assets) { asset in
          AssetView(mediaAsset: asset)
        }
        .contextMenu {
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
          
          Button {
            withAnimation { () -> () in
              currentEditor.makeBackground(from: layer)
            }
          } label: {
            Label("Make it Background", systemImage: "square.3.layers.3d.bottom.filled")
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
    .frame(
      width: currentEditor.size.width,
      height: currentEditor.size.height,
      alignment: .topLeading)
    
    //    .border(.white)
    .background(Color.white)
    //    .clipped()
  }
}
