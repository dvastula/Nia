//
//  ExportView.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 08.07.2022.
//

import SwiftUI

struct ExportView: View {
  @Binding var showing: Bool
  var image: Image
  var fileURL: URL

    var body: some View {
      ZStack {
        image
          .resizable()
          .scaledToFit()
        
        FloatPanel(.bottomLeading) {
          
          // Close button
          
          Button {
            showing.toggle()
          } label: {
            Image(systemName: "multiply")
          }
          .buttonStyle(FloatButton())
          
          // ShareLink button
          
          Button {} label: {
            ShareLink(
              item: image,
              preview: SharePreview(fileURL.lastPathComponent, image: image)
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
