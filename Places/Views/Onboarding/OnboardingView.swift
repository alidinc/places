//
//  OnboardingView.swift
//  Places
//
//  Created by alidinc on 22/01/2024.
//

import SwiftUI

struct OnboardingView: View {
    
    @Binding var hasCompletedOnboarding: Bool
    @AppStorage("tint") private var tint: Tint = .blue
    
    @Environment(LocationsManager.self) private var locationsManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @State private var selectedPage = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Content TabView
            TabView(selection: $selectedPage) {
                ForEach(Array(OnboardingPage.pages.enumerated()), id: \.element.id) { index, page in
                    Group {
                        if page.type == .features {
                            featuresPage(page)
                        } else if page.type == .location {
                            locationPage(page)
                        } else if page.type == .tint {
                            tintSelectionPage(page)
                        } else {
                            getStartedPage(page)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedPage) { oldValue, newValue in
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
            // Fixed bottom section
            
            VStack(spacing: 20) {
                stickyButton
                pageIndicators
            }
            .padding(.vertical, 50)
            .background(Color(UIColor.systemBackground))
        }
        .onChange(of: locationsManager.authorizationStatus) { oldValue, newValue in
            let currentPage = OnboardingPage.pages[selectedPage]
            if currentPage.type == .location &&
                (newValue == .authorizedWhenInUse || newValue == .authorizedAlways) {
                withAnimation {
                    selectedPage += 1
                }
            }
        }
        .animation(.easeInOut, value: selectedPage)
    }
    
    private func requestLocation() {
        locationsManager.requestAuthorisation()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        }
    }
    
    private var pageIndicators: some View {
        HStack {
            ForEach(0..<OnboardingPage.pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == selectedPage ? tint.color : .gray.opacity(0.3))
                    .frame(width: index == selectedPage ? 20 : 7, height: 7)
                    .animation(.easeInOut, value: selectedPage)
            }
        }
    }
    
    // MARK: - Page Views
    private func tintSelectionPage(_ page: OnboardingPage) -> some View {
           VStack(spacing: 32) {
               Spacer()
               
               Image(systemName: page.imageName)
                   .font(.system(size: 64))
                   .foregroundStyle(tint.color)
               
               VStack(spacing: 8) {
                   Text(page.title)
                       .font(.title.weight(.semibold))
                   
                   Text(page.subtitle)
                       .font(.body)
                       .foregroundStyle(.secondary)
                       .multilineTextAlignment(.center)
               }
               .padding(.horizontal, 32)
               
               // Color selection grid
               LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 5), spacing: 15) {
                   ForEach(Tint.allCases, id: \.self) { color in
                       Circle()
                           .fill(color.color)
                           .frame(width: 45, height: 45)
                           .overlay {
                               if color == tint {
                                   Image(systemName: "checkmark")
                                       .fontWeight(.bold)
                                       .foregroundStyle(.white)
                               }
                           }
                           .onTapGesture {
                               withAnimation(.spring) {
                                   tint = color
                               }
                           }
                   }
               }
               .padding()
               
               Spacer()
           }
       }

    
    
      private func featuresPage(_ page: OnboardingPage) -> some View {
          VStack(alignment: .leading, spacing: 32) {
              Spacer()
              
              VStack(alignment: .leading, spacing: 8) {
                  Text(page.title)
                      .font(.title.weight(.semibold))
                  
                  Text(page.subtitle)
                      .font(.body)
                      .foregroundStyle(.secondary)
              }
              .padding(.horizontal, 32)
              
              // Features list
              VStack(alignment: .leading, spacing: 24) {
                  ForEach(Feature.features) { feature in
                      FeatureRow(icon: feature.icon, title: feature.title, subtitle: feature.subtitle)
                  }
              }
              .padding(.horizontal, 32)
              
              Spacer()
          }
      }
      
      private func locationPage(_ page: OnboardingPage) -> some View {
          VStack(alignment: .leading, spacing: 32) {
              Spacer()
              
              VStack(alignment: .leading, spacing: 8) {
                  Text(page.title)
                      .font(.title.weight(.semibold))
                  
                  Text(page.subtitle)
                      .font(.body)
                      .foregroundStyle(.secondary)
              }
              .padding(.horizontal, 32)
              
              VStack(alignment: .leading, spacing: 24) {
                  ForEach(Feature.location) { feature in
                      FeatureRow(icon: feature.icon, title: feature.title, subtitle: feature.subtitle)
                  }
              }
              .padding(.horizontal, 32)
              
              Spacer()
          }
      }
      
      private func getStartedPage(_ page: OnboardingPage) -> some View {
          VStack(spacing: 32) {
              Spacer()
              
              Image(systemName: page.imageName)
                  .font(.system(size: 64))
                  .foregroundStyle(tint.color)
              
              VStack(spacing: 8) {
                  Text(page.title)
                      .font(.title.weight(.semibold))
                  
                  Text(page.subtitle)
                      .font(.body)
                      .foregroundStyle(.secondary)
                      .multilineTextAlignment(.center)
              }
              .padding(.horizontal, 32)
              
              Spacer()
          }
      }
        
    @ViewBuilder
    private var stickyButton: some View {
        Group {
            let currentPage = OnboardingPage.pages[selectedPage]
            if currentPage.type == .location {
                if locationsManager.hasRequestedAuthorization {
                    continueButton(index: selectedPage)
                } else {
                    Button(action: requestLocation) {
                        Text("Enable Location")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .foregroundStyle((scheme == .dark && tint == .black) ? .black : .white)
                    }
                    .padding(8)
                    .background(tint.color, in: .rect(cornerRadius: 12))
                    .opacity(locationsManager.hasRequestedAuthorization ? 0.5 : 1)
                    .disabled(locationsManager.hasRequestedAuthorization)
                }
            } else if currentPage.type == .getStarted {
                Button(action: completeOnboarding) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .foregroundStyle((scheme == .dark && tint == .black) ? .black : .white)
                }
                .padding(8)
                .background(tint.color, in: .rect(cornerRadius: 12))
            } else {
                continueButton(index: selectedPage)
            }
        }
        .padding(.horizontal, 32)
    }
    
    private func continueButton(index: Int) -> some View {
        Button(action: {
            withAnimation {
                selectedPage += 1
            }
        }) {
            Text("Continue")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle((scheme == .dark && tint == .black) ? .black : .white)
        }
        .padding(8)
        .background(tint.color, in: .rect(cornerRadius: 12))
    }
}

struct FeatureRow: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
                .foregroundStyle(tint.color)
                .symbolRenderingMode(.hierarchical)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
