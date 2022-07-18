//
//  PreviewView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct PreviewView: View, DropDelegate {
  
  @ObservedObject var currentEditor: Editor
  @State var dropLocation: CGPoint = .zero
  
  var body: some View {
    ZStack {
      ForEach(currentEditor.layers) { layer in
        LayerView(
          currentEditor: currentEditor,
          layer: layer
        )        
      }
    }
    .frame(
      width: currentEditor.size.width,
      height: currentEditor.size.height,
      alignment: .topLeading)
    
    //    .border(.white)
    .background(Color.white)
    .onDrop(of: [.image, .fileURL], delegate: self)
    //    .clipped()
  }
  
  func dropUpdated(info: DropInfo) -> DropProposal? {
    dropLocation = info.location
    
    return .none
  }
  
  func performDrop(info: DropInfo) -> Bool {
      print("Performing drop: \(info)")
    
      if info.hasItemsConforming(to: [.image, .jpeg, .tiff, .gif, .png, .icns, .bmp, .ico, .rawImage, .svg]) {
          let providers = info.itemProviders(for: [.image, .jpeg, .tiff, .gif, .png, .icns, .bmp, .ico, .rawImage, .svg])

          let types: [UTType] = [.image, .png, .jpeg, .tiff, .gif, .icns, .ico, .rawImage, .bmp, .svg]

          for type in types {
              for provider in providers {
                  if provider.registeredTypeIdentifiers.contains(type.identifier) {
                      print("Provider \(provider) found for \(type.identifier)")
                    
                      provider.loadDataRepresentation(forTypeIdentifier: type.identifier) { data, error in
                        DispatchQueue.main.async {
                          
                          if let data, let uiImage = UIImage(data: data) {
                            
                            let asset = Asset(
                              image: uiImage,
                              frame: CGRect(origin: dropLocation,
                                            size: uiImage.size))
                            
                            withAnimation {
                              let layer = Layer().add(asset)
                              currentEditor.add(layer)
                            }
                            
                          } else {
                            print("ERROR while image drop")
                          }
                          
                        }
                      }
                    
                      return true
                  }
              }
          }
      }
      return false
  }

  
}
