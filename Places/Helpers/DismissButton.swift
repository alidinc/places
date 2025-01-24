import SwiftUI

struct DismissButton: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 11).weight(.bold))
                .foregroundStyle(.gray.opacity(0.75))
                .padding(8)
                .background {
                    StyleManager.shared.listRowBackground
                        .clipShape(.circle)
                }
        }
    }
}

#Preview {
    DismissButton()
        .padding()
        .background(.blue)
}
