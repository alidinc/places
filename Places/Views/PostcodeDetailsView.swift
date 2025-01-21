//
//  PostcodeDetailsView.swift
//  Places
//
//  Created by alidinc on 21/12/2024.
//

import SwiftUI

struct PostcodeDetailsView: View {
    
    @AppStorage("tint") private var tint: Tint = .blue
    let country: String
    @Binding var isLoading: Bool
    @Binding var postcodeResult: PostcodeResult?
    @Binding var errorMessage: String?
    
    var body: some View {
        if country == "United Kingdom" {
            Section {
                content
            } header: {
                Text("Local Info")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 0) {
                        Text("This data is sourced from ")
                        Link("postcodes.io", destination: URL(string: "https://postcodes.io")!)
                            .foregroundStyle(tint.color)
                            .font(.footnote)
                    }
                    
                    Text("Kindly verify if the information is accurate.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
            .listRowBackground(Color.gray.opacity(0.25))
            .listRowSeparatorTint(.gray.opacity(0.45))
        }
    }
    
    @ViewBuilder
    private var content: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: tint.color))
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if let postcodeResult {
                VStack(alignment: .leading, spacing: 8) {
                    Group {
                        InfoRow(title: "Postcode", value: postcodeResult.postcode)
                        InfoRow(title: "Country", value: postcodeResult.country)
                        if let region = postcodeResult.region {
                            InfoRow(title: "Region", value: region)
                        }
                        InfoRow(title: "Admin District", value: postcodeResult.adminDistrict)
                        InfoRow(title: "Admin Ward", value: postcodeResult.adminWard)
                        
                        InfoRow(title: "Longitude", value: String(format: "%.6f", postcodeResult.longitude))
                        InfoRow(title: "Latitude", value: String(format: "%.6f", postcodeResult.latitude))
                        InfoRow(title: "NHS Health Authority", value: postcodeResult.nhsHa)
                    }
                }
                .padding(.vertical, 4)
            } else if let errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private func InfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
        .hSpacing(.leading)
        .padding(.vertical, 4)
    }
}

