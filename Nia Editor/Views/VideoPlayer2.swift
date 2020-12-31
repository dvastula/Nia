//
//  VideoPlayer2.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 13.11.2020.
//

import SwiftUI
import AVKit

// MARK: ExerciseVideoPlayer: UIViewRepresentable
struct VideoPlayer2: UIViewRepresentable {
  var videoUrl: URL
  
  func makeUIView(context: Context) -> UIView {
    LoopingVideoPlayerView(videoUrl: videoUrl)
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    // Do nothing here
  }
}

// MARK: LoopingVideoPlayerView: UIView
class LoopingVideoPlayerView: UIView {
  // MARK: Stored properties
  var videoUrl: URL
  private var playerLayer = AVPlayerLayer()
  private var playerLooper: AVPlayerLooper?
  
  // MARK: Initialization
  init(videoUrl: URL) {
    self.videoUrl = videoUrl
    super.init(frame: .zero)
    
    // Load Video
    let playerItem = AVPlayerItem(url: videoUrl)
    
    // Setup Player
    let player = AVQueuePlayer(playerItem: playerItem)
    playerLayer.player = player
    playerLayer.videoGravity = .resizeAspect
    layer.addSublayer(playerLayer)
    
    // Loop
    playerLooper = AVPlayerLooper(player: player, templateItem: playerItem)
    player.play()
  }
  
  // MARK: Methods
  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer.frame = bounds
  }
  
  
  // MARK: Whatever that is
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
