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

struct PreviewScreen: View, DropDelegate {
  @EnvironmentObject var currentEditor: Editor
  @State private var selectedPhotos: [PhotosPickerItem] = []
  @State private var lastTimeImported: Date = Date()
  
  @State private var showingExportSheet = false
  
  @State private var scale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  
  @State var dropLocation: CGPoint = .zero
  
  var mainView: some View {
    PreviewView(currentEditor: currentEditor)
      .onDrop(of: [.image, .fileURL], delegate: self)
  }
  
  var body: some View {
    
    ZStack {
      // ZStack is required for FloatPanels
      
      GeometryReader { geometry in
        let panelsPadding: Double = geometry.size.width < 500 ? 6 : 10
        
        // Preview component with content itself
        mainView
          .scaleEffect(scale)
          .rotationEffect(rotation)
          .offset(offset)
        
        // I don't know why
          .position(x: 0, y: 0)
        
        // Background filled the view
          .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
          )
          .background(Color(red: 0.3, green: 0.3, blue: 0.3))
        
        // Fit Preview in screen
          .onAppear() {
            scale = currentEditor.size.aspectFitRatio(inside: geometry.size)
            offset = geometry.size / 2
          }
        
        // Move scale rotate
          .modifier(Movable(
            scale: $scale,
            offset: $offset,
            rotation: $rotation)
          )
        
        // Action panels
        
        FloatPanel(.topLeading) {
          if !currentEditor.assets.isEmpty {
            // Remove all button
            
            Button {
              withAnimation { () -> () in
                currentEditor.removeAll()
              }
            } label: {
              Image(systemName: "trash.fill")
            }
            .buttonStyle(FloatButton())
          }
        }
        .padding(panelsPadding)
        
        FloatPanel(.topTrailing) {
          // Share button
          
          Button {
            showingExportSheet.toggle()
          } label: {
            Image(systemName: "square.and.arrow.up")
          }
          .buttonStyle(FloatButton())
          
        }
        .padding(panelsPadding)
        
        FloatPanel(.bottomLeading) {
          
          // Center and fit
          
          Button {
            scale = currentEditor.size.aspectFitRatio(inside: geometry.size)
            offset = geometry.size / 2
            rotation = .degrees(0)
          } label: {
            Image(systemName: "arrow.down.forward.and.arrow.up.backward")
              .font(.largeTitle)
          }
          .buttonStyle(FloatButton())
          
          
          // Add asset button
          
          Button {} label: {
            PhotosPicker(selection: $selectedPhotos, selectionBehavior: .ordered) {
              Image(systemName: "plus")
            }
          }
          .buttonStyle(FloatButton())
        }
        .padding(panelsPadding)
        
      }
      
    }
    
    .animation(Animation.easeInOut(duration: 0.15), value: offset)
    .animation(Animation.easeInOut(duration: 0.15), value: scale)
    .animation(Animation.easeInOut(duration: 0.15), value: rotation)
    
    // Import from Photos
    .onChange(of: selectedPhotos) { newItems in
      // Stupid hack because onChange is called million times with same values
      if Int(Date().timeIntervalSince(lastTimeImported)) < 1 {
        print("onChange was fired too fast, skip")
        return
      }
      
      lastTimeImported = Date()
      
      Task {
        try await onImageSelect(newItems)
      }
    }
    
    // Export
    .sheet(isPresented: $showingExportSheet) {
      
      if let uiImage = mainView.environmentObject(currentEditor).snapshot() {
        let image = Image(uiImage: uiImage)
        
        ExportView(image: image)
      }
    }
  }
  
  private func onImageSelect(_ newItems: [PhotosPickerItem]) async throws {
    
    for item in newItems {
      
      let newAsset = try await Importer.import(item)
      
      let randomInt = Int.random(in: 3...9)
      newAsset.frame = CGRect(x: 10 * randomInt,
                              y: 100 * randomInt,
                              width: 100 * randomInt,
                              height: 100 * randomInt)
            
      withAnimation { () -> () in
        currentEditor.add(newAsset)
      }
    }
    
    selectedPhotos = []
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
                  
                  let asset = ImageAsset(
                    image: uiImage,
                    frame: CGRect(origin: dropLocation,
                                  size: uiImage.size))
                  
                  withAnimation { () -> () in
                    currentEditor.add(asset)
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
