//
//  ExportView.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 08.07.2022.
//

import SwiftUI

struct ExportView: View {
  var image: Image
  
  var body: some View {
    ZStack {
      image
        .resizable()
        .scaledToFit()
      
      FloatPanel(.bottomLeading) {
        
        // ShareLink button
        
        Button {} label: {
          let randomPrefix = UUID().uuidString.prefix(8)
          
          ShareLink(
            item: image,
            preview: SharePreview(randomPrefix, image: image)
          ) {
            Image(systemName: "square.and.arrow.up")
          }
        }
        .buttonStyle(FloatButton())
      }
      .padding()
    }
  }
}
