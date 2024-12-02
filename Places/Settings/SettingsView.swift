//
//  SettingsView.swift
//  Forecasts
//
//  Created by Ali Dinç on 20/08/2024.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {

    @AppStorage("tint") private var tint: Tint = .blue
    @AppStorage("appIcon") private var selectedAppIcon: AppIcon = .black

    @State var store = TipStore()
    @Bindable var language: LanguageManager

    @Environment(\.colorScheme) var scheme
    @Environment(\.openURL) var openURL

    @State private var showEmailSelection = false
    @State private var showSendEmail = false
    @State private var showRateApp = false
    @State private var showShareSheet = false
    @State private var showTips = false
    @State private var showThanks = false
    @State private var showAlertNoDefaulEmailFound = false
    @State private var email = SupportEmail(
        toAddress: "alidinc.uk@outlook.com",
        subject: "Support Email",
        messageHeader: "Please describe your issue below."
    )

    var body: some View {
        List {
            settingsSection
            feedbackSection
        }
        .navigationTitle("Settings")
        .toolbarRole(.editor)
        .sensoryFeedback(.selection, trigger: tint)
        .environment(\.locale, .init(identifier: language.language.key))
        .onChange(of: store.action) { _, action in
            if action == .successful {
                showTips = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showThanks = true
                    store.reset()
                }
            }
        }
        .customAlert(isPresented: $showThanks, config: .init(
                          title: Constants.Text.PurchaseTitle,
                          subtitle: Constants.Text.PurchaseMessage,
                          primaryActions: [.init(title: "OK", action: { showThanks = false }) ])
        )
        .sheet(isPresented: $showShareSheet) { ActivityView(activityItems: [URL(string: Constants.URLs.AppStoreURL)!]) }
        .sheet(isPresented: $showSendEmail, content: {
            MailView(supportEmail: $email) { result in
                switch result {
                case .success:
                    print("Email sent")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        })
        .confirmationDialog("Rate us", isPresented: $showRateApp, titleVisibility: .visible, actions: {
            Button {
                self.rateApp()
            } label: {
                Text("Go to AppStore")
                    .font(.subheadline)
            }
        })
        .confirmationDialog("Tips", isPresented: $showTips, titleVisibility: .visible, actions: {
            ForEach(store.items, id: \.self) { item in
                Button {
                    Task {
                        await self.store.purchase(item)
                    }
                } label: {
                    Text(item.displayPrice)
                }
            }
        })
        .confirmationDialog("Send an email", isPresented: $showEmailSelection, titleVisibility: .visible, actions: {
            Button {
                self.email.send(openURL: self.openURL) { didSend in
                    showAlertNoDefaulEmailFound = !didSend
                }
            } label: {
                Text("Default email app")
                    .font(.subheadline)
            }

            if MailView.canSendMail {
                Button {
                    self.showSendEmail = true
                } label: {
                    Text("iOS email app")
                        .font(.subheadline)
                }
            }
        })
    }


    // MARK: - Settings Section

    private var settingsSection: some View {
        Section(header: Text("Settings")) {
            AppIconSelector
            TintSelector
            LocalizationView(settings: language)
        }
    }

    private var AppIconSelector: some View {
        NavigationLink(destination: AppIconSelectionView(selectedAppIcon: $selectedAppIcon)) {
            SettingsRowView(icon: "app", title: "App Icon") {
                Image(selectedAppIcon.assetName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            }
        }
    }

    private var TintSelector: some View {
        NavigationLink(destination: TintSelectionView(selectedTint: $tint)) {
            SettingsRowView(icon: "paintpalette.fill", title: "App Tint Color") {
                Circle()
                    .fill(tint.color)
                    .frame(width: 16, height: 16)
            }
        }
    }

    // MARK: - Feedback Section

    private var feedbackSection: some View {
        Section(header: Text("Feedback")) {
            Button(action: {
                showEmailSelection = true
            }) {
                SettingsRowView(icon: "envelope", title: "Send Feedback")
            }

            Button(action: {
                rateApp()
            }) {
                SettingsRowView(icon: "star.fill", title: "Rate Us")
            }

            Button(action: {
                showTips = true
            }) {
                SettingsRowView(icon: "gift.fill", title: "Send a Tip")
            }

            Button(action: {
                showShareSheet = true
            }) {
                SettingsRowView(icon: "square.and.arrow.up", title: "Share App")
            }

            NavigationLink(destination: AboutView()) {
                SettingsRowView(icon: "info.circle", title: "About")
            }
        }
    }

    // MARK: - Helper Functions

    private func rateApp() {
        guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") else { return }
        UIApplication.shared.open(url)
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
