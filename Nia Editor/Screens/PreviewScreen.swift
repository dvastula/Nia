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

struct PreviewScreen: View {
  @EnvironmentObject var currentEditor: Editor
  @State private var selectedPhotos: [PhotosPickerItem] = []
  @State private var lastTimeImported: Date = Date()
  
  @State private var showingExportSheet = false
  
  @State private var scale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  
  var mainView: some View {
    PreviewView(currentEditor: _currentEditor)
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
          if !currentEditor.layers.isEmpty {
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
            PhotosPicker(selection: $selectedPhotos) {
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
      
      let newLayer = Layer().add(newAsset)
      
      withAnimation { () -> () in
        currentEditor.add(newLayer)
      }
    }
    
    selectedPhotos = []
  }
}
