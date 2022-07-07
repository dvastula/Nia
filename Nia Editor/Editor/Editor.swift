//
//  Editor.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 07.11.2020.
//

import SwiftUI

class Editor: Identifiable, ObservableObject {
  var id = UUID()
  @Published var size: CGSize = CGSize(width: 1000, height: 2000)
  @Published var layers: [Layer] = []
  
  @discardableResult
  func add(_ newLayer: Layer) -> Editor {
    layers.append(newLayer)
    return self
  }
  
  @discardableResult
  func remove(_ newLayer: Layer) -> Editor {
    layers.removeAll { (layer) -> Bool in
      return layer.id == newLayer.id
    }
    
    return self
  }
  
  @discardableResult
  func removeAll() -> Editor {
    layers.removeAll()
    return self
  }
  
}
