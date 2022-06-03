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
  
  @State private var scale: CGFloat = 1.0


  var body: some View {
      ZStack {
        GeometryReader { geometry in

          ScrollView([.horizontal,.vertical], showsIndicators: true) {
            // Preview component with content itself
            PreviewView(currentEditor: _currentEditor)
              .scaleEffect(scale)
              .position(
                x: geometry.size.width / 2,
                y: geometry.size.height / 2)
              .frame(width: currentEditor.size.width * scale,
                     height: currentEditor.size.height * scale,
                     alignment: .bottomTrailing)
          }
          .onAppear() {
            if geometry.size < currentEditor.size {
              scale = currentEditor.size.aspectFitRatio(inside: geometry.size)
            }
          }
          .onChange(of: geometry.size) { newSize in
            print(newSize)
//            if newSize < currentEditor.size {
              scale = currentEditor.size.aspectFitRatio(inside: newSize)
//            }
          }
        }

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
      }
      .sheet(isPresented: $showingImagePicker) {
        ImagePicker() { imported in
          if let importedUIImage = imported as? UIImage {
            print("Image or Animation imported")

//            FaceRecognizer().process(image: importedUIImage.cgImage!)

            let newMedia = ImageAsset()
            newMedia.frame = CGRect(x: 10, y: 100, width: 200, height: 200)
            newMedia.image = Image(uiImage: importedUIImage)
            
            withAnimation { () -> () in
              currentEditor.add(mediaAsset: newMedia)
            }
          } else if let avAsset = imported as? AVAsset {
            print("Video imported")

//            FaceRecognizer().processVideo(asset: avAsset)
            
            let newMedia = VideoAsset(from: avAsset)

            withAnimation { () -> () in
              currentEditor.add(mediaAsset: newMedia)
            }
          }
        }
    }
  }
}

func logTime(for title: String, operation: () -> ()) {
  let startTime = CFAbsoluteTimeGetCurrent()
  operation()
  let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
  print("\(title): \(timeElapsed) s.")
}
