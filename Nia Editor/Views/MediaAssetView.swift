//
//  MediaAsset.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 09.11.2020.
//

import SwiftUI
import AVKit

struct AssetView: View {
  @ObservedObject var mediaAsset: MediaAsset
  @State private var duration: Double = 0
  
  var body: some View {
    VStack {
      HStack {
//        Spacer()
        
        mediaAsset.image
          .resizable()
          .scaledToFit()
          .frame(height: 200)
          .foregroundColor(mediaAsset.color)
          .padding()
        
//        Spacer()
      }
      
      HStack {
        Text("Duration")
        
        Spacer()
        
        Text("\(String(format: "%.1f", mediaAsset.duration)) secs")

        Stepper("Duration", onIncrement: {
          let newValue = self.duration + 0.5
          self.duration = newValue
          mediaAsset.duration = newValue
        }, onDecrement: {
          let newValue = self.duration - 0.5
          
          if newValue > 0 {
            self.duration = newValue
            mediaAsset.duration = newValue
          }
        })
        .labelsHidden()
      }
      .font(.title3)
      .padding()
      
      Spacer()
    }
    .onAppear() {
      self.duration = mediaAsset.duration
    }
  }
}

struct MediaAssetRow: View {
  @ObservedObject var mediaAsset: MediaAsset
  
  var body: some View {
    HStack(spacing: 0) {
      Spacer()
      
      mediaAsset.image
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
        .foregroundColor(mediaAsset.color)
        .padding()
      
      Spacer()
      
      Text("\(String(format: "%.1f", mediaAsset.duration)) secs")
    }
  }
}

