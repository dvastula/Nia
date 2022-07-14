//
//  MovableView.swift
//  Nia Editor
//
//  Created by Damir Minnegalimov on 12.07.2022.
//

import SwiftUI

struct Movable: ViewModifier {
  @Binding var scale: CGFloat
  @Binding var offset: CGSize
  @Binding var rotation: Angle
  
  @State private var tempScale: CGFloat = 1.0
  @State private var tempOffset: CGSize = .zero
  @State private var tempRotation: Angle = .degrees(0)
  
  @State private var isMoving: Bool = false
  
  func body(content: Content) -> some View {
    
    let rotationGesture = RotationGesture(minimumAngleDelta: .degrees(1))
      .onChanged { angle in
        isMoving = true
        rotation = angle + tempRotation
      }
      .onEnded { angle in
        isMoving = false
        
        let snappedAngle = Angle(degrees: snapped(degree: rotation.degrees))
        
        rotation = snappedAngle
        tempRotation = snappedAngle
      }
    
    let dragGesture = DragGesture()
      .onChanged { gesture in
        isMoving = true
        offset = gesture.translation + tempOffset
      }
      .onEnded { gesture in
        isMoving = false
        tempOffset = offset
      }
    
    let scaleGesture = MagnificationGesture()
      .onChanged { magnification in
        isMoving = true
        scale = magnification * tempScale
      }
      .onEnded { angle in
        isMoving = false
        tempScale = scale
      }
    
    let allGestures = dragGesture
      .simultaneously(with: rotationGesture)
      .simultaneously(with: scaleGesture)

    content
      .gesture(allGestures)
      .onChange(of: offset) { newValue in
        if !isMoving {
          tempScale = scale
          tempOffset = offset
          tempRotation = rotation
        }
      }
  }
  
  fileprivate func snapped(degree: Double) -> Double {
    let stickyAngles: [Double] = [0, 45, 90, 135, 180, 225, 270, 315]
    let snapGap = 10.0
    
    // Make it work with negative values too
    let sign = degree / abs(degree)
    
    for stickyAngle in stickyAngles {
      if (stickyAngle-snapGap...stickyAngle+snapGap).contains(abs(degree)) {
        return sign * stickyAngle
      }
    }
    
    return degree
  }
}
