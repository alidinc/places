import SwiftUI

struct DismissButton: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 10).weight(.bold))
                .foregroundStyle(.gray.opacity(0.75))
                .padding(5)
                .background(Color.gray.opacity(0.15), in: .circle)
        }
    }
}

#Preview {
    DismissButton()
        .padding()
        .background(.blue)
}
