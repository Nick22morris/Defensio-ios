import SwiftUI
import WebKit

struct NotesModalView: View {
    var node: ObjectionNode
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color("Primary").edgesIgnoringSafeArea(.all)

            VStack {
                // Dismiss Button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                }

                // ✅ Removed the ScrollView here and let WebView handle scrolling
                VStack(alignment: .leading, spacing: 20) {
                    // Title Section
                    Text(node.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)

                    Divider().background(Color.white)

                    // ✅ WebView handles its own scrolling now
                    WebView(htmlContent: combineBodyAndNotes(node: node))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
            }
        }
    }

    // Function to combine body and notes with conditional spacing
    private func combineBodyAndNotes(node: ObjectionNode) -> String {
        var combinedContent = ""
        
        if let body = node.body, !body.isEmpty {
            combinedContent += "\(body)<br><br>"
        }
        
        if let notes = node.notes, !notes.isEmpty {
            combinedContent += "<strong>Notes:</strong><br>\(notes)"
        }
        
        return combinedContent
    }
}

// WebView for rendering HTML content
struct WebView: UIViewRepresentable {
    var htmlContent: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = true // ✅ Ensuring WebView handles scrolling
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlStart = """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                body { font-family: -apple-system; font-size: 18px; color: white; background: transparent; padding: 0; margin: 0; }
                p { margin-bottom: 15px; }
                ul { padding-left: 20px; margin-bottom: 15px; }
                li { margin-bottom: 5px; }
                strong { font-weight: bold; }
                em { font-style: italic; }
                br { line-height: 30px; }
            </style>
        </head>
        <body>
        """
        let htmlEnd = "</body></html>"
        let completeHTML = htmlStart + htmlContent + htmlEnd
        webView.loadHTMLString(completeHTML, baseURL: nil)
    }
}
