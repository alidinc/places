//
//  CustomAlertView.swift
//  Steps
//
//  Created by Ali Dinç on 16/08/2024.
//

import Observation
import Combine
import SwiftUI

struct AlertAction {
    let title: String
    let action: () -> Void
    let image: Image?
    let foregroundColor: Color?
    let backgroundColor: Color?

    init(title: String, action: @escaping () -> Void, image: Image? = nil, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
        self.title = title
        self.action = action
        self.image = image
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

struct CustomAlertView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @AppStorage("tint") private var tint: Tint = .blue

    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let horizontalActions: [AlertAction]
    let verticalActions: [AlertAction]?
    let hasCancel: Bool
    let cancelAction: (() -> Void)?
    let presentationFraction: Double

    init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        horizontalActions: [AlertAction],
        verticalActions: [AlertAction]? = nil,
        hasCancel: Bool = false,
        cancelAction: (() -> Void)? = nil,
        presentationFraction: Double
    ) {
        self.title = title
        self.subtitle = subtitle
        self.horizontalActions = horizontalActions
        self.verticalActions = verticalActions
        self.hasCancel = hasCancel
        self.cancelAction = cancelAction
        self.presentationFraction = presentationFraction
    }

    var body: some View {
        VStack(alignment: .center) {
            VStack {
                Text(title)
                    .font(.title3)
                    .bold()
                    .multilineTextAlignment(.center)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                }
            }

            if horizontalActions.count > 1 {
                MultipleActionAlert
            } else {
                SingularActionAlert
            }
        }
        .padding(.horizontal, horizontalActions.count > 1 ? 20 : 40)
        .padding(.vertical, 30)
        .vSpacing(.center)
        .ignoresSafeArea()
        .presentationDetents([.fraction(self.presentationFraction)])
        .presentationBackground(Color(.systemBackground))
    }

    private var MultipleActionAlert: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(horizontalActions.indices, id: \.self) { index in
                    Button(action: {
                        horizontalActions[index].action()
                        dismiss()
                    }, label: {
                        HStack {
                            if let image = horizontalActions[index].image {
                                image
                            }
                            Text(horizontalActions[index].title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(colorForegroundBlack())
                        .background(colorForBlack().gradient, in: .rect(cornerRadius: 10, style: .continuous))
                    })
                }
            }

            if let verticalActions, !verticalActions.isEmpty {
                VStack(spacing: 8) {
                    ForEach(verticalActions.indices, id: \.self) { index in
                        Button(action: {
                            verticalActions[index].action()
                            dismiss()
                        }, label: {
                            HStack {
                                if let image = verticalActions[index].image {
                                    image
                                }
                                Text(verticalActions[index].title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(verticalActionForegroundColor(for: index))
                            .background(verticalActionBackgroundColor(for: index).gradient, in: .rect(cornerRadius: 10, style: .continuous))
                        })
                    }
                }
            }

            if hasCancel {
                Button(action: {
                    if let cancelAction {
                        cancelAction()
                        dismiss()
                    }
                }, label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .tint(.white)
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(scheme == .light ? .black : .white)
                        .background(scheme == .light ? Color.black.opacity(0.25) : Color.white.opacity(0.15),
                                    in: .rect(cornerRadius: 12, style: .continuous))
                })
            }
        }
    }

    private func verticalActionBackgroundColor(for index: Int) -> Color {
        if let verticalActions {
            if let color = verticalActions[index].backgroundColor {
                return color
            } else {
                return colorForBlack()
            }
        } else {
            return colorForBlack()
        }
    }

    private func verticalActionForegroundColor(for index: Int) -> Color {
        if let verticalActions {
            if let color = verticalActions[index].foregroundColor {
                return color
            } else {
                return scheme == .dark ? .white : .black
            }
        } else {
            return scheme == .dark ? .white : .black
        }
    }

    @ViewBuilder
    private var SingularActionAlert: some View {
        if let verticalActions, !verticalActions.isEmpty {
            VStack(spacing: 8) {
                ForEach(horizontalActions.indices, id: \.self) { index in
                    Button(action: {
                        horizontalActions[index].action()
                        dismiss()
                    }, label: {
                        HStack {
                            if let image = horizontalActions[index].image {
                                image
                            }
                            Text(horizontalActions[index].title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(verticalActionForegroundColor(for: index))
                        .background(colorForBlack().gradient, in: .rect(cornerRadius: 10, style: .continuous))
                    })
                }

                if hasCancel {
                    Button(action: {
                        if let cancelAction {
                            cancelAction()
                            dismiss()
                        }
                    }, label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .tint(.white)
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(scheme == .light ? .black : .white)
                            .background(scheme == .light ? Color.black.opacity(0.25) : Color.white.opacity(0.15),
                                        in: .rect(cornerRadius: 12, style: .continuous))
                    })
                }
            }
        } else {
            HStack(spacing: 8) {
                if hasCancel {
                    Button(action: {
                        if let cancelAction {
                            cancelAction()
                            dismiss()
                        }
                    }, label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .tint(.white)
                            .frame(height: 45)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(scheme == .light ? .black : .white)
                            .background(scheme == .light ? Color.black.opacity(0.25) : Color.white.opacity(0.15),
                                        in: .rect(cornerRadius: 12, style: .continuous))
                    })
                }

                ForEach(horizontalActions.indices, id: \.self) { index in
                    Button(action: {
                        horizontalActions[index].action()
                        dismiss()
                    }, label: {
                        HStack {
                            if let image = horizontalActions[index].image {
                                image
                            }
                            Text(horizontalActions[index].title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(height: 45)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(colorForegroundBlack())
                        .background(colorForBlack().gradient, in: .rect(cornerRadius: 10, style: .continuous))
                    })
                }
            }
        }
    }

    func colorForBlack() -> Color {
        if tint == .black && scheme == .dark {
            return Color.white
        } else if tint == .black && scheme == .light {
            return Color.black
        } else {
            return tint.color
        }
    }

    func colorForegroundBlack() -> Color {
        if tint == .black && scheme == .dark {
            return Color.black
        } else {
            return Color.white
        }
    }
}

struct AlertConfig {
    let title: LocalizedStringResource
    let subtitle: LocalizedStringResource?
    let primaryActions: [AlertAction]
    let secondaryActions: [AlertAction]?
    let hasCancel: Bool
    let cancelAction: (() -> Void)?

    init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource? = nil,
        primaryActions: [AlertAction],
        secondaryActions: [AlertAction]? = nil,
        hasCancel: Bool = false,
        cancelAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.primaryActions = primaryActions
        self.secondaryActions = secondaryActions
        self.hasCancel = hasCancel
        self.cancelAction = cancelAction
    }
}

struct CustomAlert: ViewModifier {

    @Binding var isPresented: Bool
    let publisher: NotificationCenter.Publisher?
    let config: AlertConfig
    let object: ((Notification) -> Void)?
    let onDisappear: (() -> Void)?
    let presentationFraction: Double

    func body(content: Content) -> some View {
        if let publisher {
            content
                .onReceive(publisher) { notification in
                    isPresented = true
                    if let object {
                        object(notification)
                    }
                }
                .sheet(isPresented: $isPresented, content: {
                    CustomAlertView(
                        title: config.title,
                        subtitle: config.subtitle,
                        horizontalActions: config.primaryActions,
                        verticalActions: config.secondaryActions,
                        hasCancel: config.hasCancel,
                        cancelAction: config.cancelAction,
                        presentationFraction: presentationFraction
                    )
                    .onTapGesture {
                        isPresented.toggle()
                    }
                })
                .onDisappear {
                    if let onDisappear {
                        onDisappear()
                    }
                }
        } else {
            content
                .sheet(isPresented: $isPresented, content: {
                    CustomAlertView(
                        title: config.title,
                        subtitle: config.subtitle,
                        horizontalActions: config.primaryActions,
                        verticalActions: config.secondaryActions,
                        hasCancel: config.hasCancel,
                        cancelAction: config.cancelAction,
                        presentationFraction: presentationFraction
                    )
                    .onTapGesture {
                        isPresented.toggle()
                    }
                })
                .onDisappear {
                    if let onDisappear {
                        onDisappear()
                    }
                }
        }
    }
}

extension View {
    func customAlert(
        onReceive: NotificationCenter.Publisher? = nil,
        isPresented: Binding<Bool>,
        config: AlertConfig,
        object: ((Notification) -> Void)? = nil,
        onDisappear: (() -> Void)? = nil,
        presentationFraction: Double = 0.22
    ) -> some View {
        modifier(
            CustomAlert(
                isPresented: isPresented,
                publisher: onReceive,
                config: config,
                object: object,
                onDisappear: onDisappear,
                presentationFraction: presentationFraction
            )
        )
    }
}
