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
    @Bindable var language: LanguageManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var scheme
    @Environment(\.openURL) var openURL
    @State private var showEmailSelection = false
    @State private var showSendEmail = false
    @State private var showRateApp = false
    @State private var showShareSheet = false
    @State private var showTints = false
    @State private var showAbout = false
    @State private var showLanguage = false
    @State private var showIcons = false
    @State private var showTips = false
    @State private var showThanks = false
    @State private var showAlertNoDefaulEmailFound = false
    @State var store = TipStore()
    @State private var email = SupportEmail(
        toAddress: "alidinc.uk@outlook.com",
        subject: "Support Email",
        messageHeader: "Please describe your issue below."
    )
    
    @State private var showOnboarding = false

    var body: some View {
        NavigationStack {
            List {
                settingsSection
                feedbackSection
            }
            .padding(.top, -16)
            .scrollContentBackground(.hidden)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { DismissButton() } }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .sensoryFeedback(.selection, trigger: tint)
            .environment(\.locale, .init(identifier: language.language.key))
            .onAppear { HapticsManager.shared.vibrateForSelection() }
            .sheet(isPresented: $showSendEmail) { mailButton }
            .sheet(isPresented: $showTints) { TintSelectionView(selectedTint: $tint) }
            .sheet(isPresented: $showIcons) { AppIconSelectionView(selectedAppIcon: $selectedAppIcon)  }
            .sheet(isPresented: $showLanguage) { LanguageSelectionView(selectedLanguage: $language.language) }
            .sheet(isPresented: $showAbout) { AboutView() }
            .fullScreenCover(isPresented: $showOnboarding) { OnboardingView(hasCompletedOnboarding: $showOnboarding, hasSkip: true) }
            .sheet(isPresented: $showShareSheet) {
                ActivityView(activityItems: [URL(string: Constants.URLs.AppStoreURL)!])
                    .presentationDetents([.medium, .large])
            }
            .confirmationDialog("Rate us", isPresented: $showRateApp, titleVisibility: .visible, actions: { rateButton })
            .confirmationDialog("Tips", isPresented: $showTips, titleVisibility: .visible, actions: { tipActions })
            .confirmationDialog("Send an email", isPresented: $showEmailSelection, titleVisibility: .visible, actions: { emailDialogActions })
            .customAlert(isPresented: $showThanks, config: .init(
                              title: Constants.Text.PurchaseTitle,
                              subtitle: Constants.Text.PurchaseMessage,
                              primaryActions: [.init(title: "OK", action: { showThanks = false }) ])
            )
            .onChange(of: store.action) { _, action in
                if action == .successful {
                    showTips = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showThanks = true
                        store.reset()
                    }
                }
            }
        }
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium, .fraction(0.95)])
        .presentationCornerRadius(20)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        Section(header: Text("Settings")) {
            appIconSelector
            tintSelector
            languageSelector
            showOnboardingButton
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
    
    private var showOnboardingButton: some View {
        Button {
            showOnboarding = true
        } label: {
            SettingsRowView(icon: "info.circle.fill", title: "View Onboarding")
        }
    }
    
    private var languageSelector: some View {
        Button {
            showLanguage = true
        } label: {
            SettingsRowView(icon: "globe", title: "Language") {
                Text("\(language.language.flag) \(language.language.title)")
            }
        }
    }

    private var appIconSelector: some View {
        Button {
            showIcons = true
        } label: {
            SettingsRowView(icon: "app", title: "App Icon") {
                Image(selectedAppIcon.assetName)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .cornerRadius(4)
            }
        }
    }

    private var tintSelector: some View {
        Button {
            showTints = true
        } label: {
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
                showRateApp = true
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

            Button {
                showAbout = true
            } label: {
                SettingsRowView(icon: "info.circle", title: "About")
            }
        }
        .listRowBackground(StyleManager.shared.listRowBackground)
        .listRowSeparatorTint(StyleManager.shared.listRowSeparator)
    }
    
    @ViewBuilder
    private var emailDialogActions: some View {
        Button {
            self.email.send(openURL: self.openURL) { didSend in
                showAlertNoDefaulEmailFound = !didSend
            }
        } label: {
            Text("Default email app")
        }

        if MailView.canSendMail {
            Button {
                self.showSendEmail = true
            } label: {
                Text("iOS email app")
            }
        }
    }
    
    @ViewBuilder
    private var tipActions: some View {
        ForEach(store.items, id: \.self) { item in
            Button {
                Task {
                    await self.store.purchase(item)
                }
            } label: {
                Text(item.displayPrice)
            }
        }
    }
    
    private var mailButton: some View {
        MailView(supportEmail: $email) { result in
            switch result {
            case .success:
                print("Email sent")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private var rateButton: some View {
        Button {
            guard let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") else { return }
            UIApplication.shared.open(url)
        } label: {
            Text("Go to AppStore")
        }
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


