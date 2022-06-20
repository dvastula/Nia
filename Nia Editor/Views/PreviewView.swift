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
      ForEach(currentEditor.assets) { mediaAsset in
        StickerView(mediaAsset: mediaAsset)
          .onTapGesture(count: 2) {
            withAnimation { () -> () in
              currentEditor.remove(mediaAsset: mediaAsset)
            }
          }
      }
    }
    .background(Color.red)
    .frame(width: currentEditor.size.width,
           height: currentEditor.size.height,
           alignment: .topLeading)
    
    .background(previewBackground)
//    .clipped()
  }
}
