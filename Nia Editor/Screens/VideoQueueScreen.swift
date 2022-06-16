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
      
      }
      .navigationBarItems(trailing:
                            Button {
                            } label: {
                              Image(systemName: "square.and.arrow.up")
                            }
                            .font(.largeTitle)
      )
    }
  }
}

