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
  
  @State var lastSnapshotURL: URL?
  @State private var showingExportSheet = false
  
  @State private var tempScale: CGFloat = 1.0
  @State private var tempOffset: CGSize = .zero
  @State private var tempRotation: Angle = .degrees(0)
  
  @State private var scale: CGFloat = 1.0
  @State private var offset: CGSize = .zero
  @State private var rotation: Angle = .degrees(0)
  
  var mainView: some View {
    PreviewView(currentEditor: _currentEditor)
  }
  
  var body: some View {
    let rotationGesture = RotationGesture(minimumAngleDelta: .degrees(1))
      .onChanged { angle in
        rotation = angle + tempRotation
      }
      .onEnded { angle in
        tempRotation = rotation
      }
    
    let dragGesture = DragGesture()
      .onChanged { gesture in
        offset = gesture.translation + tempOffset
      }
      .onEnded { gesture in
        tempOffset = offset
      }
    
    let scaleGesture = MagnificationGesture()
      .onChanged { magnification in
        scale = magnification * tempScale
      }
      .onEnded { angle in
        tempScale = scale
      }
    
    let allGestures = dragGesture
      .simultaneously(with: rotationGesture)
      .simultaneously(with: scaleGesture)
    
    ZStack {
      GeometryReader { geometry in
        
        ZStack {
          // Preview component with content itself
          mainView
            .onAppear() {
              tempScale = currentEditor.size.aspectFitRatio(inside: geometry.size)
              tempOffset = geometry.size / 2
              
              scale = tempScale
              offset = tempOffset
            }
//            .onChange(of: geometry.size) { newSize in
//              scale = currentEditor.size.aspectFitRatio(inside: newSize)
//            }
          
            .frame(width: currentEditor.size.width,
                   height: currentEditor.size.height)
            .scaleEffect(scale)
            .rotationEffect(rotation)
            .offset(offset)
          
            .position(
              x: 0,
              y: 0)
          
        }
        .frame(
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .topLeading
        )
        .background(Color.gray.opacity(0.3))
      }
      
      // Action panel
      
      FloatPanel(.bottomLeading) {
        
        if !currentEditor.layers.isEmpty {
          
          // Share button
          
          Button {
            Task {
              lastSnapshotURL = Exporter.export(mainView.environmentObject(currentEditor))
              showingExportSheet.toggle()
            }
          } label: {
            Image(systemName: "square.and.arrow.up")
              .font(.largeTitle)
          }
          .buttonStyle(FloatButton())
          
          
          // Remove all button
          
          Button {
            withAnimation { () -> () in
              currentEditor.removeAll()
            }
          } label: {
            Image(systemName: "trash.fill")
              .font(.largeTitle)
          }
          .buttonStyle(FloatButton())
        }
        
        // Add asset button
        
        Button {} label: {
          PhotosPicker(selection: $selectedPhotos) {
            Image(systemName: "plus")
              .font(.largeTitle)
          }
        }
        .buttonStyle(FloatButton())
      }
      .padding()
      
    }
    
    .gesture(allGestures)
    
    .animation(Animation.easeInOut(duration: 0.15), value: offset)
    .animation(Animation.easeInOut(duration: 0.15), value: scale)
    .animation(Animation.easeInOut(duration: 0.15), value: rotation)
    
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
    .sheet(isPresented: $showingExportSheet) {
      
      if let lastSnapshotURL {
        let uiImage = UIImage(contentsOfFile: lastSnapshotURL.path())!
        let image = Image(uiImage:uiImage)
        
        ExportView(
          showing: $showingExportSheet,
          image: image,
          fileURL: lastSnapshotURL)
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
