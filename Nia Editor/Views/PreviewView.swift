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
    .frame(maxWidth: .infinity,
           minHeight: 100,
           maxHeight: 500,
           alignment: .topLeading)
    .background(Color.blue)
    .aspectRatio(CGSize(width: 1000, height: 1250),
                 contentMode: .fit)
    .background(previewBackground)
    .clipped()
  }
}
