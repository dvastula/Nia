//
//  ContentView.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 07.11.2020.
//

import SwiftUI
import AVKit

struct VideoQueueScreen: View {
  @EnvironmentObject var currentEditor: Editor
  @State private var showingImagePicker = false
  @State private var avPlayer: AVPlayer = AVPlayer()
  
  var body: some View {
    NavigationView {
      ZStack {
        VStack {
          VideoPlayer(player: self.avPlayer)
            .frame(height: 200)
          
          List(currentEditor.assets) { mediaAsset in
            NavigationLink(destination: AssetView(mediaAsset: mediaAsset)) {
              MediaAssetRow(mediaAsset: mediaAsset)
            }
          }.listStyle(PlainListStyle())
        }
        
        FloatPanel() {
          FloatButton(imageName: "plus") {
            self.showingImagePicker = true
          }.padding(.bottom, 8)
          
          FloatButton(imageName: "play.fill") {
            let item = AVPlayerItem(asset: currentEditor.prepareComposition())
            self.avPlayer = AVPlayer(playerItem: item)
            self.avPlayer.play()
          }
        }
      }
      .navigationBarItems(trailing:
                            Button {
                            } label: {
                              Image(systemName: "square.and.arrow.up")
                            }
                            .font(.largeTitle)
      )
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker() { imported in
        if let importedUIImage = imported as? UIImage {
          print("Image or Animation imported")
          
          let newMedia = MediaAsset()
          newMedia.image = Image(uiImage: importedUIImage)
          
          currentEditor.add(mediaAsset: newMedia)
        } else if let avAsset = imported as? AVAsset {
          print("Video imported")
          
          let newMedia = VideoAsset(from: avAsset)
          
          currentEditor.add(mediaAsset: newMedia)
        }
      }
    }
  }
}

