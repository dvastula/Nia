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
            .onTapGesture(count: 2) {
              withAnimation { () -> () in
                layer.remove(asset)
                
                if layer.assets.count == 0 {
                  currentEditor.layers.removeAll { $0.id == layer.id }
                }
              }
            }
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
