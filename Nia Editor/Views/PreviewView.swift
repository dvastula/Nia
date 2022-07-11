//
//  PreviewView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI

fileprivate let previewBackground = colors.randomElement()!

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
      }
    }
    .frame(width: currentEditor.size.width,
           height: currentEditor.size.height,
           alignment: .topLeading)
    .border(.white)
    .background(Color.white)
//    .clipped()
  }
}
