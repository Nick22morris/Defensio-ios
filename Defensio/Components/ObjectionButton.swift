import SwiftUI

// MARK: - Objection Button Component (Left-Aligned Text)
struct ObjectionButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .font(.title2)
                    .multilineTextAlignment(.leading)  // Ensure left alignment for wrapped text
                    .lineLimit(nil)                    // Allow text wrapping
                    .fixedSize(horizontal: false, vertical: true)  // Prevent text from truncating
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)  // Left-align entire content
            .background(Color("Primary"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white, lineWidth: 1)
            )
        }
        .padding(5)
    }
}

#Preview {
    ObjectionButton(title: "Example Left-Aligned Button") {
        print("Button tapped!")
    }
}
