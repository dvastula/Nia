//
//  PreviewScreen.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit
import PhotosUI
import Photos

enum ScaleMode {
  case fixed,
       draggable
}

struct PreviewScreen: View {
  @EnvironmentObject var currentEditor: Editor
  @State private var scale: CGFloat = 1.0
    var scaleMode: ScaleMode = .draggable
    
  
  @State var selectedPhotos: [PhotosPickerItem] = []
  
  var body: some View {
      ZStack {
        GeometryReader { geometry in

          ScrollView(scaleMode == .fixed ? [] : [.horizontal, .vertical], showsIndicators: true) {
            // Preview component with content itself
            
            PreviewView(currentEditor: _currentEditor)
              .scaleEffect(scale)
              .frame(width: currentEditor.size.width * scale,
                     height: currentEditor.size.height * scale,
                     alignment: .bottomTrailing)
              .position(
                x: currentEditor.size.width / 2,
                y: currentEditor.size.height / 2)
          }
          .onAppear() {
//            if geometry.size < currentEditor.size {
              scale = currentEditor.size.aspectFitRatio(inside: geometry.size)
//            }
          }
          .onChange(of: geometry.size) { newSize in
//            if newSize < currentEditor.size {
              scale = currentEditor.size.aspectFitRatio(inside: newSize)
//            }
          }
        }

        FloatPanel() {
          if self.currentEditor.assets.count > 0 {
            Button {
              withAnimation { () -> () in
                self.currentEditor.removeAll()
              }
            } label: {
              Image(systemName: "trash.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
            }
            .buttonStyle(FloatButton())
            .padding(.bottom, 5)
          }
          
          Button {
            withAnimation { () -> () in
              self.currentEditor.removeAll()
            }
          } label: {
            PhotosPicker(selection: $selectedPhotos) {
              Image(systemName: "plus")
                .font(.largeTitle)
                .foregroundColor(.white)
            }
            .onChange(of: selectedPhotos) { newItems in
              for item in newItems {
                
                Task {
                  if let data = try? await item.loadTransferable(type: Data.self) {
                    
                    if let uiImage = UIImage(data: data) {
                      print("Image or Animation imported")
                      
                      // FaceRecognizer().process(image: uiImage.cgImage!)
                      let randomInt = Int.random(in: 3...9)
                      
                      let newMedia = ImageAsset()
                      newMedia.frame = CGRect(x: 10 * randomInt,
                                              y: 100 * randomInt,
                                              width: 100 * randomInt,
                                              height: 100 * randomInt)
                      newMedia.image = Image(uiImage: uiImage)
                      
                      withAnimation { () -> () in
                        currentEditor.add(mediaAsset: newMedia)
                      }
                    }
                  }
                }
              }
              
              selectedPhotos = []
            }
          }
          .buttonStyle(FloatButton())
        }
      }
  }
}
