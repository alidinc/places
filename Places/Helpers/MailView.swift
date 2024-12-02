//
//  MailView.swift
//  Steps
//
//  Created by Ali Dinç on 14/08/2024.
//

import SwiftUI
import UIKit
import MessageUI

struct SupportEmail {
    let toAddress: String
    let subject: String
    let messageHeader: String
    var data: Data?

    var body: String { """
Application Name: \(Bundle.main.appName)
iOS: \(UIDevice.current.systemVersion)
Device model: \(UIDevice.current.model)
App version: \(Bundle.main.appVersionLong)
App build: \(Bundle.main.appBuild)
\(messageHeader)
--------------------------------------------
"""
    }

    func send(openURL: OpenURLAction, completion: @escaping (Bool) -> Void) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"

        guard let url = URL(string: urlString) else {
            return
        }

        openURL(url) { accepted in
            completion(accepted)
            if !accepted {
                print(
"""
This device does not support email
\(body)
"""
                )
            }
        }
    }
}

typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var supportEmail: SupportEmail
    let callback: MailViewCallback

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var presentation: PresentationMode
        @Binding var data: SupportEmail
        let callback: MailViewCallback

        init(presentation: Binding<PresentationMode>,
             data: Binding<SupportEmail>,
             callback: MailViewCallback) {
            _presentation = presentation
            _data = data
            self.callback = callback
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            if let error = error {
                callback?(.failure(error))
            } else {
                callback?(.success(result))
            }
            $presentation.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(presentation: presentation, data: $supportEmail, callback: callback)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(supportEmail.subject)
        vc.setToRecipients([supportEmail.toAddress])
        vc.setMessageBody(supportEmail.body, isHTML: false)
        if let data = supportEmail.data {
            vc.addAttachmentData(data, mimeType: "text/plain", fileName: "\(Bundle.main.appName).json")
        }
        vc.accessibilityElementDidLoseFocus()
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
    }

    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}
