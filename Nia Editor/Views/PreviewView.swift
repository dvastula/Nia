//
//  PreviewView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI

fileprivate let previewBackground = darkColors.randomElement()!

struct PreviewView: View {
  @EnvironmentObject var currentEditor: Editor
  @State private var scale: CGFloat = 1.0

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
    
    .scaleEffect(scale)

    .background(previewBackground)
    .aspectRatio(currentEditor.size,
                 contentMode: .fit)
    .clipped()
  }
}
