//
//  PreviewView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct PreviewView: View {
  
  @ObservedObject var currentEditor: Editor
  
  var body: some View {
    ZStack {
      ForEach(currentEditor.assets) { asset in
        AssetView(
          currentEditor: currentEditor,
          asset: asset
        )        
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
