//
//  Editor.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 07.11.2020.
//

import SwiftUI
import AVFoundation

class Editor: Identifiable, ObservableObject {
  var id = UUID()
  @Published var assets: [MediaAsset] = []
  
  @discardableResult
  func add(mediaAsset: MediaAsset) -> Editor {
    assets.append(mediaAsset)
    return self
  }
  
  @discardableResult
  func remove(mediaAsset: MediaAsset) -> Editor {
    assets.removeAll { (asset) -> Bool in
      return asset.id == mediaAsset.id
    }
    
    return self
  }
  
  @discardableResult
  func removeAll() -> Editor {
    assets.removeAll()
    return self
  }
  
  @discardableResult
  func prepareComposition() -> AVMutableComposition {
    let mixComposition = AVMutableComposition(urlAssetInitializationOptions: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
    
    mixComposition.naturalSize = .init(width: 4000, height: 4000)
    //    mixComposition.duration =
    
    for asset in assets {
      if let videoAsset = asset as? VideoAsset {
        let avAsset = videoAsset.avAsset
        
        let maxTime = mixComposition.getMaxTimeOfTracks()
        mixComposition.add(avAsset: avAsset, to: maxTime)
      }
    }
    
    
    return mixComposition
  }
}

fileprivate extension AVMutableComposition {
  func add(avAsset: AVAsset, to time: CMTime = .zero) {
    print("Adding asset to time \(time.seconds) with duration \(avAsset.duration.seconds)")
    
    let newTrack = self.addMutableTrack(withMediaType: .video,
                                        preferredTrackID: kCMPersistentTrackID_Invalid)
    let assetTrack = avAsset.tracks(withMediaType: .video)[0]
    
    do {
      try newTrack?.insertTimeRange(CMTimeRange(start: .zero,
                                                end: avAsset.duration),
                                    of: assetTrack,
                                    at: time)
      
      newTrack?.preferredTransform = assetTrack.preferredTransform
    } catch {
      print("Error = \(error.localizedDescription)")
    }
  }
  
  func getMaxTimeOfTracks() -> CMTime {
    var maxTime: CMTime = .zero
    
    for track in self.tracks(withMediaType: .video) {
      if track.timeRange.end > maxTime {
        maxTime = track.timeRange.end
      }
    }
    
    return maxTime
  }
}
