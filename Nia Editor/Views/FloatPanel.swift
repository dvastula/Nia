//
//  FloatPanel.swift
//  Nia Editor
//
//  Created by Damik Minnegalimov on 09.11.2020.
//

import SwiftUI

let floatingButtonRadius: CGFloat = 35
let customAccentColor: Color = Color(#colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1))

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


struct FloatButton: View {
  let imageName: String
  let action: () -> ()
  
  var body: some View {
    Button {
      action()
    } label: {
      Image(systemName: imageName)
        .font(.largeTitle)
        .foregroundColor(.white)
        .frame(width: floatingButtonRadius * 2,
               height: floatingButtonRadius * 2)
    }
    .background(customAccentColor)
    .cornerRadius(floatingButtonRadius)
  }
}
