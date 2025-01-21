//
//  HUD.swift
//  Places
//
//  Created by alidinc on 21/01/2025.
//

import SwiftUI

struct HUD<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    content
      .padding(.horizontal, 12)
      .padding(12)
      .background(
        Capsule()
            .foregroundStyle(.regularMaterial)
           
      )
  }
}

extension View {
  func hud<Content: View>(
    isPresented: Binding<Bool>,
    @ViewBuilder content: () -> Content
  ) -> some View {
    ZStack(alignment: .top) {
      self

      if isPresented.wrappedValue {
        HUD(content: content)
          .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
          .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
              withAnimation {
                isPresented.wrappedValue = false
              }
            }
          }
          .zIndex(1)
      }
    }
  }
}
