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
        NavigationStack {
            VStack(spacing: 20) {
                Text("Places is designed to help you keep track of your personal journey, making it simple to record and remember every place you've called home. You can also store addresses of friends and family, making it your personal address book with a story.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TeamMemberView

                Spacer()

                Marquee(targetVelocity: 50) {
                    Button {
                        showSafari = true
                    } label: {
                        CustomSelectionView(assetName: scheme == .dark ? "Icon5" : "Icon",
                                            title: "Places \(Bundle.main.appVersionLong)",
                                            subtitle: "Built with SwiftUI and ❤️",
                                            config: .init(titleFont: .system(size: 12),
                                                          titleFontWeight: .medium,
                                                          subtitleFont: .caption2,
                                                          subtitleFontWeight: .regular,
                                                          showChevron: false))
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
            .toolbar { ToolbarItem(placement: .topBarTrailing, content: { DismissButton() }) }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSafari, content: { SFSafariView(url: URL(string: Constants.URLs.SwiftUI)!).ignoresSafeArea()  })
        }
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
        .presentationBackground(.thinMaterial)
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

                    Text("Developer")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()


                if let url = URL(string: Constants.URLs.LinkedIn(profile: "ali-dinc/")) {
                    Link(destination: url) {
                        Image(.linkedin)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .hSpacing(.trailing)
                }
            }
            .padding(.horizontal)

        }
        .padding(.vertical)
        .background {
            StyleManager.shared.listRowSeparator
                .clipShape(.rect(cornerRadius: 12))
        }
    }
}
