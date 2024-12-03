//
//  HeaderView.swift
//  Places
//
//  Created by alidinc on 02/12/2024.
//

import SwiftData
import SwiftUI

struct HeaderView: View {

    @Query private var savedAddresses: [Place]

    var body: some View {
        Group {
            Text(savedAddresses.count, format: .number)
                .font(.system(size: 80).weight(.semibold))
                .contentTransition(.numericText())
        }
        .frame(height: UIScreen.main.bounds.height / 4.5)
    }
}
