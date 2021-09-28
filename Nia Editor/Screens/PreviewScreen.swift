//
//  PreviewScreen.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit

struct PreviewScreen: View {
  @EnvironmentObject var currentEditor: Editor
  @State private var showingImagePicker = false
  
  var body: some View {
    NavigationView {
      VStack {
        // Preview component with content itself
        PreviewView(currentEditor: _currentEditor)

        // Panels
        Spacer()
      }
      .overlay(
        FloatPanel() {
          if self.currentEditor.assets.count > 0 {
            FloatButton(imageName: "trash.fill") {
              withAnimation { () -> () in
                self.currentEditor.removeAll()
              }
            }
            .padding(.bottom, 5)
            
          }
          FloatButton(imageName: "plus") {
            self.showingImagePicker = true
          }
        }
      )
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker() { imported in
        if let importedUIImage = imported as? UIImage {
          print("Image or Animation imported")

          FaceRecognizer().process(image: importedUIImage.cgImage!)

          let newMedia = ImageAsset()
          newMedia.frame = CGRect(x: 10, y: 100, width: 200, height: 200)
          newMedia.image = Image(uiImage: importedUIImage)
          
          withAnimation { () -> () in
            currentEditor.add(mediaAsset: newMedia)
          }
        } else if let avAsset = imported as? AVAsset {
          print("Video imported")

          FaceRecognizer().processVideo(asset: avAsset)
          
          let newMedia = VideoAsset(from: avAsset)

          withAnimation { () -> () in
            currentEditor.add(mediaAsset: newMedia)
          }
        }
      }
    }
  }
}

