//
//  SFSafariView.swift
//  Steps
//
//  Created by Ali Dinç on 14/08/2024.
//

import SafariServices
import SwiftUI
import UIKit

struct SFSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
     //   config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: url, configuration: config)
        return vc
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        // No need to do anything here
    }
}
