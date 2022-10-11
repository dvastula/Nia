//
//  Editor.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 07.11.2020.
//

import SwiftUI

enum VerticalDirection {
  case up
  case down
}

class Editor: Identifiable, ObservableObject {
  var id = UUID()
  @Published var size: CGSize = CGSize(width: 1080, height: 1920)
  @Published var assets: [Asset] = []
  
  @discardableResult
  func add(_ newAsset: Asset) -> Editor {
    assets.append(newAsset)
    return self
  }
  
  @discardableResult
  func remove(_ newAsset: Asset) -> Editor {
    assets.removeAll { (asset) -> Bool in
      return asset.id == newAsset.id
    }
    
    return self
  }
  
  @discardableResult
  func move(_ asset: Asset, _ direction: VerticalDirection) -> Editor {
    
    if let currentIndex = assets.firstIndex(of: asset) {
      
      if direction == .up && currentIndex < assets.count - 1 {
        assets.insert(asset, at: currentIndex + 2)
        assets.remove(at: currentIndex)
      } else if direction == .down && currentIndex > 0 {
        assets.insert(asset, at: currentIndex - 1)
        assets.remove(at: currentIndex + 1)
      }
      
    }
    
    return self
  }
  
  @discardableResult
  func lock(_ asset: Asset) -> Editor {
    asset.locked = true
    return self
  }
  
  @discardableResult
  func unlock(_ asset: Asset) -> Editor {
    asset.locked = false
    return self
  }
  
  @discardableResult
  func makeBackground(from asset: Asset) -> Editor {
    
    while let currentIndex = assets.firstIndex(of: asset),
            currentIndex > 0 {
      move(asset, .down)
    }
    
    let firstAssetImage = asset.image
    size = firstAssetImage.size
    
    asset.offset = .zero
    asset.scale = 1
    asset.rotation = .zero
    asset.frame = CGRect(origin: .zero, size: firstAssetImage.size)
      
    
    return self
  }
  
  @discardableResult
  func removeAll() -> Editor {
    assets.removeAll()
    return self
  }
  
}
