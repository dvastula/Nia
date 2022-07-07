//
//  FloatPanel.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 09.11.2020.
//

import SwiftUI

let floatingButtonRadius: CGFloat = 40

/// View with two buttons
/// Should be always be a last child in ZStack
struct FloatPanel<Content: View>: View {
  let content: Content
  let position: Alignment
  let direction: Axis.Set
  
  init(_ position: Alignment, _ direction: Axis.Set = .vertical, @ViewBuilder builder: () -> Content) {
    content = builder()
    self.position = position
    self.direction = direction
  }
      
  var body: some View {
                
    switch position {
    case .topLeading:
      HStack {
        VStack {
          if direction == .vertical {
            content
          } else {
            HStack {
              content
            }
          }
          
          Spacer()
        }
        
        Spacer()
      }
      
    case .topTrailing:
      HStack {
        Spacer()
        
        VStack {
          if direction == .vertical {
            content
          } else {
            HStack {
              content
            }
          }
          Spacer()
        }
      }
      
    case .bottomLeading:
      HStack {
        VStack {
          Spacer()
          if direction == .vertical {
            content
          } else {
            HStack {
              content
            }
          }
        }
        
        Spacer()
      }
      
    case .bottomTrailing:
      HStack {
        Spacer()

        VStack {
          Spacer()
          if direction == .vertical {
            content
          } else {
            HStack {
              content
            }
          }
        }
      }
      
    default:
      HStack {
        VStack {
          Spacer()
          if direction == .vertical {
            content
          } else {
            HStack {
              content
            }
          }
        }
        
        Spacer()
      }
    }
  }
}

struct FloatButton: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  
  func makeBody(configuration: Configuration) -> some View {
    configuration
      .label
      .foregroundColor(.primary)
      .padding()
      .frame(width: floatingButtonRadius * 2, height: floatingButtonRadius * 2)
      .background(.ultraThinMaterial)
      .cornerRadius(floatingButtonRadius)
      .hoverEffect(.lift)
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
  }
}
