//
//  FloatPanel.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 09.11.2020.
//

import SwiftUI

let floatingButtonRadius: CGFloat = 40
let customAccentColor: Color = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))

/// View with two buttons
/// Should be always be a last child in ZStack
struct FloatPanel<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder builder: () -> Content) {
    self.content = builder()
  }
  
  var body: some View {
    HStack {
      VStack {
        Spacer()
        self.content
      }
      .padding()
      
      Spacer()
    }
  }
}

struct FloatButton: ButtonStyle {
  @Environment(\.isEnabled) private var isEnabled
  
  func makeBody(configuration: Configuration) -> some View {
    configuration
      .label
      .padding()
      .background(customAccentColor)
      .cornerRadius(floatingButtonRadius)
      .hoverEffect(.lift)
  }
}
