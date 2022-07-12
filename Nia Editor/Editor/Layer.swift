//
//  Layer.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 07.07.2022.
//

import Foundation

class Layer: Identifiable, ObservableObject, Equatable {
  var id = UUID()
  @Published var assets: [Asset] = []
  
  @discardableResult
  func add(_ mediaAsset: Asset) -> Layer {
    assets.append(mediaAsset)
    return self
  }
  
  @discardableResult
  func remove(_ mediaAsset: Asset) -> Layer {
    assets.removeAll { (asset) -> Bool in
      return asset.id == mediaAsset.id
    }
    
    return self
  }
  
  static func == (lhs: Layer, rhs: Layer) -> Bool {
      return lhs.id == rhs.id
  }
}
