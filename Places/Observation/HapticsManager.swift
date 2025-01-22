//
//  HapticsManager.swift
//  Places
//
//  Created by alidinc on 22/01/2025.
//


import CoreHaptics
import UIKit

final class HapticsManager {

	static let shared = HapticsManager()

	private init() { }

	// MARK: - Public

	public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
		let generator = UINotificationFeedbackGenerator()
		generator.prepare()
		generator.notificationOccurred(type)
	}

	public func vibrateForSelection() {
		let generator = UISelectionFeedbackGenerator()
		generator.prepare()
		generator.selectionChanged()
	}

	func vibrate(type: UINotificationFeedbackGenerator.FeedbackType) {
		let generator = UINotificationFeedbackGenerator()
		generator.prepare()
		generator.notificationOccurred(type)
	}
}