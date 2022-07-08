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
  @State private var scale: CGFloat = 1.0
  @State private var selectedPhotos: [PhotosPickerItem] = []
  @State private var lastTimeImported: Date = Date()
 
  @State var lastSnapshotURL: URL?
  @State private var showingExportSheet = false

  var mainView: some View {
    PreviewView(currentEditor: _currentEditor)
      .scaleEffect(scale)
      .frame(width: currentEditor.size.width * scale,
             height: currentEditor.size.height * scale,
             alignment: .bottomTrailing)
      .position(
        x: currentEditor.size.width / 2,
        y: currentEditor.size.height / 2)
  }

  var body: some View {
      ZStack {
        GeometryReader { geometry in

          ScrollView([], showsIndicators: true) {
            // Preview component with content itself
            mainView
          }
          .onAppear() {
            scale = currentEditor.size.aspectFitRatio(inside: geometry.size)
          }
          .onChange(of: geometry.size) { newSize in
            scale = currentEditor.size.aspectFitRatio(inside: newSize)
          }
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
