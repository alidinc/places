//
//  AboutView.swift
//  Steps
//
//  Created by Ali Dinç on 14/08/2024.
//

import SwiftUI

struct AboutView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.colorScheme) private var scheme

    @State private var showSafari = false
    @State private var showWeatherData = false

    var body: some View {
        VStack(spacing: 20) {
            Text("I've designed Places with a focus on minimalism, and functionality, ensuring it meets the needs of everyone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TeamMemberView

            Spacer()

            Marquee(targetVelocity: 50) {
                CustomSelectionView(assetName: scheme == .dark ? "Icon5" : "Icon",
                                    title: "Places \(Bundle.main.appVersionLong)",
                                    subtitle: "Built with SwiftUI and ❤️",
                                    config: .init(titleFont: .system(size: 12),
                                                  titleFontWeight: .medium,
                                                  subtitleFont: .caption2,
                                                  subtitleFontWeight: .regular,
                                                  showChevron: false))
                .onTapGesture { showSafari = true }
            }
            .padding(.bottom, 40)
        }
        .padding()
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSafari, content: { SFSafariView(url: URL(string: Constants.URLs.SwiftUI)!).ignoresSafeArea()  })
    }

    @ViewBuilder
    private var TeamMemberView: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "person.fill")
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text("Ali Dinç")
                        .font(.headline.bold())
                        .foregroundColor(.primary)

                    Text("Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()


                HStack {
                    if let url = URL(string: Constants.URLs.LinkedIn(profile: "ali-dinc/")) {
                        Link(destination: url) {
                            Image(.linkedin)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    }

                    if let url = URL(string: Constants.URLs.ThreadsURL) {
                        Link(destination: url) {
                            Image(.threads)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }

                }
                .hSpacing(.trailing)
            }
            .padding(.horizontal)

        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 12))
    }
}
